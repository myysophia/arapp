#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PROJECT_REF="${ARAPP_SUPABASE_PROJECT_REF:-zlcnljlbuimlzhwpyrlj}"

if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
  echo "检测到 SUPABASE_ACCESS_TOKEN，将使用环境变量授权部署。"
else
  echo "未检测到 SUPABASE_ACCESS_TOKEN，尝试使用 supabase login 会话授权部署。"
fi

echo "开始部署 Edge Function: v1 (project: ${PROJECT_REF})"
supabase functions deploy v1 --project-ref "$PROJECT_REF"
echo "部署完成。"
