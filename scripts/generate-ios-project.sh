#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "未检测到 xcodegen。"
  echo "当前已提供 project.yml 与 SwiftUI 源码骨架。"
  echo "如需生成 .xcodeproj，请先在获得确认后安装 xcodegen。"
  exit 1
fi

cd "$ROOT"
xcodegen generate
echo "已生成 Xcode 工程。"
