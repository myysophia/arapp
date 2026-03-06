#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/ninesun/projects/arapp"
WORKTREE_ROOT="/Users/ninesun/projects/arapp-worktrees"

declare -a TASKS=(
  "codex/nin-7-ios-scaffold:nin-7-ios-scaffold"
  "codex/nin-8-design-tokens:nin-8-design-tokens"
  "codex/nin-9-models-mocks:nin-9-models-mocks"
  "codex/nin-10-test-baseline:nin-10-test-baseline"
)

mkdir -p "$WORKTREE_ROOT"

cd "$ROOT"

for item in "${TASKS[@]}"; do
  branch="${item%%:*}"
  dir="${item##*:}"
  target="$WORKTREE_ROOT/$dir"

  if [ -d "$target" ]; then
    echo "已存在 worktree: $target"
    continue
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$target" "$branch"
  else
    git worktree add -b "$branch" "$target" main
  fi

  echo "已创建: $target -> $branch"
done

echo
echo "Wave 0 worktrees 已准备完成。"
echo "根目录: $WORKTREE_ROOT"
git worktree list
