#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
DERIVED_DATA_PATH="${IOS_DERIVED_DATA_PATH:-$ROOT_DIR/.build/DerivedData}"

find_xcodegen() {
  if [[ -n "${XCODEGEN_BIN:-}" && -x "${XCODEGEN_BIN}" ]]; then
    echo "${XCODEGEN_BIN}"
    return 0
  fi

  if command -v xcodegen >/dev/null 2>&1; then
    command -v xcodegen
    return 0
  fi

  if [[ -x "$HOME/.local/bin/xcodegen" ]]; then
    echo "$HOME/.local/bin/xcodegen"
    return 0
  fi

  return 1
}

if [[ -f "Package.swift" ]] && ! find . -maxdepth 2 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) | grep -q .; then
  echo "检测到 Swift Package，执行 swift test。"
  swift test
  exit 0
fi

workspace="$(find . -maxdepth 2 -name "*.xcworkspace" | head -n 1 || true)"
project="$(find . -maxdepth 2 -name "*.xcodeproj" | head -n 1 || true)"

if [[ -z "$workspace" && -z "$project" ]]; then
  if [[ -f "project.yml" ]]; then
    if xcodegen_bin="$(find_xcodegen)"; then
      echo "检测到 project.yml，使用 XcodeGen 生成工程。"
      "$xcodegen_bin" generate
      workspace="$(find . -maxdepth 2 -name "*.xcworkspace" | head -n 1 || true)"
      project="$(find . -maxdepth 2 -name "*.xcodeproj" | head -n 1 || true)"
    else
      echo "检测到 project.yml，但未找到 xcodegen，无法生成工程。"
      exit 1
    fi
  else
    echo "未检测到 iOS 工程，跳过 iOS 构建与测试。"
    exit 0
  fi
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "未找到 xcodebuild，无法执行 iOS 测试。"
  exit 1
fi

list_args=()
if [[ -n "$workspace" ]]; then
  list_args=(-workspace "$workspace")
else
  list_args=(-project "$project")
fi

scheme="${IOS_SCHEME:-}"
if [[ -z "$scheme" ]]; then
  list_json="$(xcodebuild "${list_args[@]}" -list -json)"
  scheme="$(LIST_JSON="$list_json" python3 - <<'PY'
import json
import os

data = json.loads(os.environ["LIST_JSON"])
workspace = data.get("workspace", {})
project = data.get("project", {})
schemes = workspace.get("schemes") or project.get("schemes") or []
print(schemes[0] if schemes else "")
PY
)"
fi

if [[ -z "$scheme" ]]; then
  echo "无法自动识别 Scheme，请设置环境变量 IOS_SCHEME。"
  exit 1
fi

destination="${IOS_DESTINATION:-}"
if [[ -z "$destination" ]]; then
  simctl_output="$(xcrun simctl list devices available)"
  simulator_name="$(
    SIMCTL_OUTPUT="$simctl_output" python3 - <<'PY'
import os
import re

for raw in os.environ["SIMCTL_OUTPUT"].splitlines():
    line = raw.strip()
    match = re.match(r"^(iPhone .*?) \([A-F0-9-]+\) \((Shutdown|Booted)\)$", line)
    if match:
        print(match.group(1))
        break
PY
  )"

  if [[ -z "$simulator_name" ]]; then
    echo "未找到可用 iPhone 模拟器，请先安装 iOS Simulator Runtime。"
    exit 1
  fi

  destination="platform=iOS Simulator,name=$simulator_name"
fi

echo "执行 iOS 测试，Scheme: $scheme"
mkdir -p "$DERIVED_DATA_PATH"
xcodebuild \
  "${list_args[@]}" \
  -scheme "$scheme" \
  -destination "$destination" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  clean test
