#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
import urllib.parse
from typing import Any, Tuple


class RLSCheckError(Exception):
    pass


class RLSSkip(Exception):
    pass


def to_bool(value: str | None) -> bool:
    if value is None:
        return False
    return value.strip().lower() in {"1", "true", "yes", "on"}


def read_env(name: str, required: bool = False) -> str | None:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        if required:
            raise RLSCheckError(f"缺少环境变量：{name}")
        return None
    return value.strip()


def request_json(
    method: str,
    url: str,
    headers: dict[str, str],
    body: dict[str, Any] | list[dict[str, Any]] | None,
    timeout: int,
) -> Tuple[int, Any, str]:
    cmd = [
        "curl",
        "-sS",
        "--max-time",
        str(timeout),
        "-X",
        method,
        "-w",
        "\n__HTTP_STATUS__:%{http_code}",
    ]
    for key, value in headers.items():
        cmd.extend(["-H", f"{key}: {value}"])
    if body is not None:
        cmd.extend(["--data-binary", json.dumps(body, ensure_ascii=False)])
    cmd.append(url)

    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RLSCheckError(f"curl 请求失败：{proc.stderr.strip()}")

    output = proc.stdout
    marker = "\n__HTTP_STATUS__:"
    if marker not in output:
        raise RLSCheckError("响应解析失败：缺少 HTTP 状态标记")
    raw_text, status_text = output.rsplit(marker, 1)
    text = raw_text.strip()
    status = int(status_text.strip())

    if text == "":
        return status, None, ""
    try:
        return status, json.loads(text), text
    except json.JSONDecodeError:
        return status, None, text


def supabase_auth_login(base_url: str, anon_key: str, email: str, password: str, timeout: int) -> tuple[str, str]:
    url = f"{base_url}/auth/v1/token?grant_type=password"
    headers = {
        "apikey": anon_key,
        "Authorization": f"Bearer {anon_key}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    status, payload, text = request_json(
        method="POST",
        url=url,
        headers=headers,
        body={"email": email, "password": password},
        timeout=timeout,
    )
    if status != 200 or not isinstance(payload, dict):
        raise RLSCheckError(f"登录失败（{email}）：HTTP {status}，响应：{text}")

    token = payload.get("access_token")
    user = payload.get("user") or {}
    user_id = user.get("id")
    if not isinstance(token, str) or token == "":
        raise RLSCheckError(f"登录失败（{email}）：缺少 access_token")
    if not isinstance(user_id, str) or user_id == "":
        raise RLSCheckError(f"登录失败（{email}）：缺少 user.id")
    return token, user_id


def supabase_rest(
    base_url: str,
    anon_key: str,
    access_token: str,
    method: str,
    path_and_query: str,
    timeout: int,
    body: dict[str, Any] | list[dict[str, Any]] | None = None,
    extra_headers: dict[str, str] | None = None,
) -> tuple[int, Any, str]:
    headers = {
        "apikey": anon_key,
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json",
    }
    if body is not None:
        headers["Content-Type"] = "application/json"
    if extra_headers:
        headers.update(extra_headers)

    url = f"{base_url}/rest/v1/{path_and_query.lstrip('/')}"
    return request_json(method=method, url=url, headers=headers, body=body, timeout=timeout)


def is_rls_rejection(status: int, payload: Any, text: str) -> bool:
    if status in {401, 403}:
        return True

    parts: list[str] = []
    if isinstance(payload, dict):
        for key in ("message", "hint", "details", "code"):
            value = payload.get(key)
            if isinstance(value, str):
                parts.append(value)
    parts.append(text)
    merged = " ".join(parts).lower()
    return "row-level security" in merged or "42501" in merged


def is_missing_table(payload: Any, table_name: str) -> bool:
    if not isinstance(payload, dict):
        return False
    code = payload.get("code")
    message = payload.get("message")
    if not isinstance(code, str) or not isinstance(message, str):
        return False
    return code == "PGRST205" and table_name in message


def ensure_b_device_exists(base_url: str, anon_key: str, token_b: str, user_b_id: str, timeout: int) -> None:
    b_user_q = urllib.parse.quote(user_b_id, safe="")
    device_query = f"devices?select=id,user_id&user_id=eq.{b_user_q}&limit=1"
    status_b_devices, payload_b_devices, text_b_devices = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_b,
        method="GET",
        path_and_query=device_query,
        timeout=timeout,
    )
    if status_b_devices != 200 or not isinstance(payload_b_devices, list):
        if is_missing_table(payload_b_devices, "public.devices"):
            raise RLSCheckError(
                "数据库缺少 public.devices（PGRST205）。请先执行 schema/RLS 迁移后再跑 RLS 自动化。"
            )
        raise RLSCheckError(f"读取 B 的 devices 失败：HTTP {status_b_devices} 响应：{text_b_devices}")

    if len(payload_b_devices) > 0:
        return

    seed_body = [
        {
            "user_id": user_b_id,
            "device_id": f"rls-seed-{int(time.time())}",
            "platform": "ios",
            "is_active": True,
        }
    ]
    seed_status, seed_payload, seed_text = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_b,
        method="POST",
        path_and_query="devices",
        timeout=timeout,
        body=seed_body,
        extra_headers={"Prefer": "return=representation"},
    )
    if seed_status not in {200, 201}:
        detail = seed_text
        if isinstance(seed_payload, (dict, list)):
            detail = json.dumps(seed_payload, ensure_ascii=False)
        raise RLSCheckError(f"B 用户补充 devices 测试数据失败：HTTP {seed_status} 响应：{detail}")


def pick_location_id(
    base_url: str,
    anon_key: str,
    token_b: str,
    timeout: int,
    fallback_location: str | None,
) -> str:
    if fallback_location is not None and fallback_location.strip() != "":
        return fallback_location

    status_locations, payload_locations, text_locations = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_b,
        method="GET",
        path_and_query="locations?select=id&is_active=eq.true&limit=1",
        timeout=timeout,
    )
    if status_locations == 200 and isinstance(payload_locations, list) and len(payload_locations) > 0:
        first = payload_locations[0]
        if isinstance(first, dict):
            location_id = first.get("id")
            if isinstance(location_id, str) and location_id.strip() != "":
                return location_id

    if is_missing_table(payload_locations, "public.locations"):
        raise RLSCheckError(
            "数据库缺少 public.locations（PGRST205）。请先执行 schema/RLS 迁移后再跑 RLS 自动化。"
        )

    raise RLSCheckError(
        "前置条件不满足：无法确定可用 location_id。"
        "请设置 ARAPP_RLS_LOCATION_ID，或在数据库准备至少一条 is_active=true 的 locations 数据。"
        f"（HTTP {status_locations} 响应：{text_locations}）"
    )


def ensure_runnable_or_skip(required_mode: bool) -> None:
    required_vars = [
        "ARAPP_SUPABASE_URL",
        "ARAPP_SUPABASE_ANON_KEY",
        "ARAPP_RLS_USER_A_EMAIL",
        "ARAPP_RLS_USER_A_PASSWORD",
        "ARAPP_RLS_USER_B_EMAIL",
        "ARAPP_RLS_USER_B_PASSWORD",
    ]
    missing = [name for name in required_vars if read_env(name) is None]
    if not missing:
        return

    msg = "缺少环境变量：" + ", ".join(missing)
    if required_mode:
        raise RLSCheckError(msg)
    raise RLSSkip(msg)


def main() -> int:
    required_mode = to_bool(os.getenv("ARAPP_RLS_REQUIRED"))
    verbose = to_bool(os.getenv("ARAPP_RLS_VERBOSE"))

    try:
        ensure_runnable_or_skip(required_mode=required_mode)
    except RLSSkip as skip:
        print(f"RLS 越权测试跳过：{skip}")
        return 0

    base_url = read_env("ARAPP_SUPABASE_URL", required=True)
    assert base_url is not None
    base_url = base_url.rstrip("/")
    anon_key = read_env("ARAPP_SUPABASE_ANON_KEY", required=True)
    assert anon_key is not None

    user_a_email = read_env("ARAPP_RLS_USER_A_EMAIL", required=True)
    user_a_password = read_env("ARAPP_RLS_USER_A_PASSWORD", required=True)
    user_b_email = read_env("ARAPP_RLS_USER_B_EMAIL", required=True)
    user_b_password = read_env("ARAPP_RLS_USER_B_PASSWORD", required=True)
    assert user_a_email and user_a_password and user_b_email and user_b_password

    timeout = int(read_env("ARAPP_RLS_TIMEOUT_SECONDS") or "15")
    fallback_location = read_env("ARAPP_RLS_LOCATION_ID")
    fallback_threshold = read_env("ARAPP_RLS_THRESHOLD_LEVEL") or "moderate"

    print("开始执行 RLS 越权测试（RLS-001 / RLS-002）...")
    token_a, user_a_id = supabase_auth_login(base_url, anon_key, user_a_email, user_a_password, timeout)
    token_b, user_b_id = supabase_auth_login(base_url, anon_key, user_b_email, user_b_password, timeout)
    print(f"已登录测试账号：A={user_a_id} B={user_b_id}")

    ensure_b_device_exists(
        base_url=base_url,
        anon_key=anon_key,
        token_b=token_b,
        user_b_id=user_b_id,
        timeout=timeout,
    )

    b_user_q = urllib.parse.quote(user_b_id, safe="")
    device_query = f"devices?select=id,user_id&user_id=eq.{b_user_q}&limit=1"
    status_a_devices, payload_a_devices, text_a_devices = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_a,
        method="GET",
        path_and_query=device_query,
        timeout=timeout,
    )
    if status_a_devices != 200 or not isinstance(payload_a_devices, list):
        raise RLSCheckError(f"RLS-001 请求失败：HTTP {status_a_devices} 响应：{text_a_devices}")
    if len(payload_a_devices) > 0:
        raise RLSCheckError(f"RLS-001 失败：A 读取到了 B 的 devices 记录：{json.dumps(payload_a_devices, ensure_ascii=False)}")
    print("PASS RLS-001：A 用户无法读取 B 用户 devices。")

    subscription_query = f"alert_subscriptions?select=id,location_id,threshold_level,enabled&user_id=eq.{b_user_q}&limit=1"
    status_b_sub, payload_b_sub, text_b_sub = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_b,
        method="GET",
        path_and_query=subscription_query,
        timeout=timeout,
    )
    if status_b_sub != 200 or not isinstance(payload_b_sub, list):
        raise RLSCheckError(f"读取 B 的 alert_subscriptions 失败：HTTP {status_b_sub} 响应：{text_b_sub}")

    threshold = fallback_threshold
    enabled = True
    location_id = pick_location_id(
        base_url=base_url,
        anon_key=anon_key,
        token_b=token_b,
        timeout=timeout,
        fallback_location=fallback_location,
    )
    if len(payload_b_sub) > 0:
        first = payload_b_sub[0]
        if isinstance(first, dict):
            raw_location = first.get("location_id")
            if isinstance(raw_location, str) and raw_location.strip() != "":
                location_id = raw_location
            raw_threshold = first.get("threshold_level")
            if isinstance(raw_threshold, str) and raw_threshold.strip() != "":
                threshold = raw_threshold
            raw_enabled = first.get("enabled")
            if isinstance(raw_enabled, bool):
                enabled = raw_enabled

    body = [
        {
            "user_id": user_b_id,
            "location_id": location_id,
            "threshold_level": threshold,
            "enabled": enabled,
            "quiet_hours": {"enabled": True, "start": "22:00", "end": "07:00"},
        }
    ]

    status_upsert, payload_upsert, text_upsert = supabase_rest(
        base_url=base_url,
        anon_key=anon_key,
        access_token=token_a,
        method="POST",
        path_and_query="alert_subscriptions?on_conflict=user_id,location_id",
        timeout=timeout,
        body=body,
        extra_headers={"Prefer": "resolution=merge-duplicates,return=representation"},
    )

    if is_rls_rejection(status_upsert, payload_upsert, text_upsert):
        print("PASS RLS-002：A 用户无法写入 B 用户 alert_subscriptions。")
    else:
        detail = text_upsert
        if isinstance(payload_upsert, (dict, list)):
            detail = json.dumps(payload_upsert, ensure_ascii=False)
        raise RLSCheckError(f"RLS-002 失败：越权写入未被拒绝，HTTP {status_upsert} 响应：{detail}")

    if verbose:
        print("调试信息：")
        print(f"- location_id={location_id}")
        print(f"- threshold_level={threshold}")
        print(f"- enabled={enabled}")

    print("RLS 越权测试通过。")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except RLSCheckError as err:
        print(f"RLS 越权测试失败：{err}", file=sys.stderr)
        sys.exit(2)
