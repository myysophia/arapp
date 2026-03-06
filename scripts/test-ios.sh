#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "Package.swift" ]] && ! find . -maxdepth 2 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) | grep -q .; then
  echo "检测到 Swift Package，执行 swift test。"
  swift test
  exit 0
fi

workspace="$(find . -maxdepth 2 -name "*.xcworkspace" | head -n 1 || true)"
project="$(find . -maxdepth 2 -name "*.xcodeproj" | head -n 1 || true)"

if [[ -z "$workspace" && -z "$project" ]]; then
  echo "未检测到 iOS 工程，跳过 iOS 构建与测试。"
  exit 0
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
  scheme="$(xcodebuild "${list_args[@]}" -list -json | python3 - <<'PY'
import json, sys
data = json.load(sys.stdin)
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

destination="${IOS_DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

echo "执行 iOS 测试，Scheme: $scheme"
xcodebuild \
  "${list_args[@]}" \
  -scheme "$scheme" \
  -destination "$destination" \
  clean test
