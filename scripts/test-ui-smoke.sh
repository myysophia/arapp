#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTOTYPE_DIR="$ROOT_DIR/prototype/homepage"
PORT="${UI_SMOKE_PORT:-4173}"
PAGES=(index login map alerts profile onboarding system mobile-core states-overlays)

if [[ ! -d "$PROTOTYPE_DIR" ]]; then
  echo "未找到原型目录：$PROTOTYPE_DIR"
  exit 1
fi

server_started=0
server_pid=""

cleanup() {
  if [[ $server_started -eq 1 && -n "$server_pid" ]]; then
    kill "$server_pid" >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

if ! curl -fsS "http://localhost:${PORT}/index.html" >/dev/null 2>&1; then
  (
    cd "$PROTOTYPE_DIR"
    python3 -m http.server "$PORT" >/tmp/arapp-ui-smoke.log 2>&1
  ) &
  server_pid=$!
  server_started=1
  sleep 2
fi

for page in "${PAGES[@]}"; do
  url="http://localhost:${PORT}/${page}.html"
  code="$(curl -s -o /dev/null -w '%{http_code}' "$url")"
  if [[ "$code" != "200" ]]; then
    echo "页面检查失败：$url -> $code"
    exit 1
  fi
done

echo "UI 原型冒烟测试通过。"
