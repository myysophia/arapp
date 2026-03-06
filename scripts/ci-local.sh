#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

run_step() {
  local name="$1"
  shift
  echo ""
  echo "==> $name"
  "$@"
}

run_step "秘钥扫描" bash scripts/check-secrets.sh
run_step "文档一致性检查" bash scripts/check-doc-consistency.sh
run_step "UI 原型冒烟测试" bash scripts/test-ui-smoke.sh
run_step "iOS 构建与测试" bash scripts/test-ios.sh

echo ""
echo "本地 CI 全部通过。"
