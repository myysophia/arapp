#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import subprocess
import sys
from typing import Any, Tuple


class AuthExchangeCheckError(Exception):
    pass


class AuthExchangeSkip(Exception):
    pass


def to_bool(value: str | None) -> bool:
    if value is None:
        return False
    return value.strip().lower() in {"1", "true", "yes", "on"}


def read_env(name: str, required: bool = False) -> str | None:
    value = os.getenv(name)
    if value is None or value.strip() == "":
        if required:
            raise AuthExchangeCheckError(f"缺少环境变量：{name}")
        return None
    return value.strip()


def request_json(
    method: str,
    url: str,
    headers: dict[str, str],
    body: dict[str, Any] | None,
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
        raise AuthExchangeCheckError(f"curl 请求失败：{proc.stderr.strip()}")

    output = proc.stdout
    marker = "\n__HTTP_STATUS__:"
    if marker not in output:
        raise AuthExchangeCheckError("响应解析失败：缺少 HTTP 状态标记")
    raw_text, status_text = output.rsplit(marker, 1)
    text = raw_text.strip()
    status = int(status_text.strip())

    if text == "":
        return status, None, ""
    try:
        return status, json.loads(text), text
    except json.JSONDecodeError:
        return status, None, text


def ensure_runnable_or_skip(required_mode: bool) -> None:
    required_vars = [
        "ARAPP_SUPABASE_URL",
        "ARAPP_SUPABASE_ANON_KEY",
        "ARAPP_EDGE_BASE_URL",
        "ARAPP_AUTH_TEST_EMAIL",
        "ARAPP_AUTH_TEST_PASSWORD",
    ]
    missing = [name for name in required_vars if read_env(name) is None]
    if not missing:
        return

    msg = "缺少环境变量：" + ", ".join(missing)
    if required_mode:
        raise AuthExchangeCheckError(msg)
    raise AuthExchangeSkip(msg)


def supabase_password_login(
    supabase_url: str,
    anon_key: str,
    email: str,
    password: str,
    timeout: int,
) -> tuple[str, str]:
    url = f"{supabase_url.rstrip('/')}/auth/v1/token?grant_type=password"
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
        raise AuthExchangeCheckError(f"Supabase 登录失败：HTTP {status}，响应：{text}")

    access_token = payload.get("access_token")
    user = payload.get("user") or {}
    user_id = user.get("id")
    if not isinstance(access_token, str) or access_token == "":
        raise AuthExchangeCheckError("Supabase 登录失败：缺少 access_token")
    if not isinstance(user_id, str) or user_id == "":
        raise AuthExchangeCheckError("Supabase 登录失败：缺少 user.id")
    return access_token, user_id


def parse_body_json(raw: str | None) -> dict[str, Any]:
    if raw is None or raw.strip() == "":
        return {}
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as err:
        raise AuthExchangeCheckError(f"ARAPP_AUTH_EXCHANGE_BODY_JSON 不是合法 JSON：{err}") from err
    if not isinstance(payload, dict):
        raise AuthExchangeCheckError("ARAPP_AUTH_EXCHANGE_BODY_JSON 必须是 JSON 对象。")
    return payload


def assert_invalid_jwt_rejected(
    *,
    method: str,
    url: str,
    timeout: int,
    body: dict[str, Any],
    user_access_token: str,
) -> None:
    invalid_headers = {
        "Authorization": "Bearer invalid.jwt.token.for.regression",
        "X-ArApp-User-JWT": user_access_token,
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-ArApp-Client": "ci-auth-exchange-invalid-jwt",
    }
    status, _payload, text = request_json(
        method=method,
        url=url,
        headers=invalid_headers,
        body=body,
        timeout=timeout,
    )
    if 200 <= status < 300:
        raise AuthExchangeCheckError(
            "无效 JWT 未被拒绝（收到 2xx），请检查是否误将 functions.v1.verify_jwt 设为 false。"
        )
    if status not in {401, 403}:
        raise AuthExchangeCheckError(
            f"无效 JWT 回归断言失败：期望 401/403，实际 HTTP {status}，响应：{text}"
        )
    print("PASS AUTH-EXCHANGE-002：无效 JWT 被网关拒绝（401/403）。")


def main() -> int:
    required_mode = to_bool(os.getenv("ARAPP_AUTH_EXCHANGE_REQUIRED"))
    verbose = to_bool(os.getenv("ARAPP_AUTH_EXCHANGE_VERBOSE"))

    try:
        ensure_runnable_or_skip(required_mode=required_mode)
    except AuthExchangeSkip as skip:
        print(f"auth/exchange 联调测试跳过：{skip}")
        return 0

    supabase_url = read_env("ARAPP_SUPABASE_URL", required=True)
    anon_key = read_env("ARAPP_SUPABASE_ANON_KEY", required=True)
    edge_base_url = read_env("ARAPP_EDGE_BASE_URL", required=True)
    test_email = read_env("ARAPP_AUTH_TEST_EMAIL", required=True)
    test_password = read_env("ARAPP_AUTH_TEST_PASSWORD", required=True)
    assert supabase_url and anon_key and edge_base_url and test_email and test_password

    timeout = int(read_env("ARAPP_AUTH_EXCHANGE_TIMEOUT_SECONDS") or "15")
    method = (read_env("ARAPP_AUTH_EXCHANGE_METHOD") or "POST").upper()
    exchange_path = read_env("ARAPP_AUTH_EXCHANGE_PATH") or "/v1/auth/exchange"
    exchange_body = parse_body_json(read_env("ARAPP_AUTH_EXCHANGE_BODY_JSON"))
    expect_invalid_jwt_reject = to_bool(
        read_env("ARAPP_AUTH_EXCHANGE_EXPECT_INVALID_JWT_REJECT")
        or ("1" if required_mode else "0")
    )

    print("开始执行 auth/exchange 联调测试...")
    access_token, user_id = supabase_password_login(
        supabase_url,
        anon_key,
        test_email,
        test_password,
        timeout,
    )
    print(f"已获取测试用户会话：user_id={user_id}")

    url = f"{edge_base_url.rstrip('/')}/{exchange_path.lstrip('/')}"
    headers = {
        # 网关 verify_jwt=true 下，使用项目 anon JWT 作为网关令牌；
        # 真实用户会话 JWT 通过业务头传递给 auth/exchange 逻辑消费。
        "Authorization": f"Bearer {anon_key}",
        "X-ArApp-User-JWT": access_token,
        "Accept": "application/json",
        "Content-Type": "application/json",
        "X-ArApp-Client": "ci-auth-exchange",
    }
    status, payload, text = request_json(
        method=method,
        url=url,
        headers=headers,
        body=exchange_body,
        timeout=timeout,
    )

    if status in {404, 405, 501} and not required_mode:
        print(f"auth/exchange 联调测试跳过：端点未就绪（HTTP {status}）。")
        return 0

    if not (200 <= status < 300):
        raise AuthExchangeCheckError(f"auth/exchange 请求失败：HTTP {status}，响应：{text}")

    if not isinstance(payload, dict):
        raise AuthExchangeCheckError(f"auth/exchange 响应不是 JSON 对象：{text}")

    missing_fields = [name for name in ("request_id", "code", "message", "retryable") if name not in payload]
    if missing_fields:
        raise AuthExchangeCheckError(f"auth/exchange 响应缺少契约字段：{', '.join(missing_fields)}")

    print("PASS AUTH-EXCHANGE-001：/v1/auth/exchange 返回 2xx 且契约字段完整。")
    if expect_invalid_jwt_reject:
        assert_invalid_jwt_rejected(
            method=method,
            url=url,
            timeout=timeout,
            body=exchange_body,
            user_access_token=access_token,
        )
    if verbose:
        print(f"调试信息：status={status} request_id={payload.get('request_id')} code={payload.get('code')}")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except AuthExchangeCheckError as err:
        print(f"auth/exchange 联调测试失败：{err}", file=sys.stderr)
        sys.exit(2)
