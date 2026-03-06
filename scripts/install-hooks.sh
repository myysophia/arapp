#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "当前目录还不是 Git 仓库。请先执行 git init 并添加远程仓库。"
  exit 1
fi

git config core.hooksPath .githooks
chmod +x .githooks/pre-push

echo "已启用版本化 Git hooks。当前使用 .githooks/pre-push"
