#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "TODO.md"
  "docs/plans/phase-1/00-project-charter.md"
  "docs/plans/phase-1/01-product-scope-prd.md"
  "docs/plans/phase-1/02-ui-ux-spec.md"
  "docs/plans/phase-1/03-auth-supabase-oauth.md"
  "docs/plans/phase-1/04-data-provider-strategy.md"
  "docs/plans/phase-1/05-db-schema-supabase.sql.md"
  "docs/plans/phase-1/06-api-edge-functions-contract.md"
  "docs/plans/phase-1/07-alerts-push-workflow.md"
  "docs/plans/phase-1/08-i18n-l10n-spec.md"
  "docs/plans/phase-1/09-privacy-compliance-cn.md"
  "docs/plans/phase-1/10-testing-acceptance-plan.md"
  "docs/plans/phase-1/11-release-observability-runbook.md"
  "docs/plans/phase-1/12-risk-decision-log.md"
  "docs/plans/phase-1/ui/02a-home-screen-spec.md"
  "docs/plans/phase-1/ui/02b-map-screen-spec.md"
  "docs/plans/phase-1/ui/02c-alerts-screen-spec.md"
  "docs/plans/phase-1/ui/02d-profile-screen-spec.md"
)

missing=0

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "缺少文档文件：$file"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  exit 1
fi

echo "文档结构检查通过。"
