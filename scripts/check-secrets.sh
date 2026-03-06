#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-full}"

cd "$ROOT_DIR"

if ! command -v python3 >/dev/null 2>&1; then
  echo "未找到 python3，无法执行秘钥扫描。"
  exit 1
fi

python3 - "$MODE" "$ROOT_DIR" <<'PY'
import os
import re
import subprocess
import sys
from pathlib import Path

mode = sys.argv[1]
root = Path(sys.argv[2])

skip_ext = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".pdf", ".xlsx", ".xls",
    ".xlsm", ".doc", ".docx", ".zip", ".tar", ".gz", ".tgz", ".mp4", ".mov",
    ".heic", ".ttf", ".otf", ".woff", ".woff2", ".xcassets", ".pbxproj",
}
skip_dirs = {
    ".git", ".build", "DerivedData", "node_modules", ".swiftpm", ".idea",
    ".vscode", "__pycache__",
}

line_patterns = [
    ("AWS Access Key", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("GitHub Token", re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b")),
    ("GitHub PAT", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
    ("OpenAI Key", re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b")),
    ("Google API Key", re.compile(r"\bAIza[0-9A-Za-z\-_]{35}\b")),
    ("Slack Token", re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b")),
    (
        "通用敏感变量赋值",
        re.compile(
            r"(?i)\b(?:api[_-]?key|secret|token|password|passwd|private[_-]?key|service[_-]?role[_-]?key)\b"
            r"\s*[:=]\s*[\"']?[A-Za-z0-9_\-\/+=.]{12,}[\"']?"
        ),
    ),
]
block_patterns = [
    ("Private Key Block", re.compile(r"-----BEGIN (?:RSA |DSA |EC |OPENSSH |PGP )?PRIVATE KEY-----")),
]

allow_markers = ("gitleaks:allow", "secret-scan:allow")


def is_binary(path: Path) -> bool:
    try:
        with path.open("rb") as fh:
            chunk = fh.read(4096)
        return b"\x00" in chunk
    except OSError:
        return True


def staged_files():
    try:
        out = subprocess.check_output(
            ["git", "diff", "--cached", "--name-only", "--diff-filter=ACMR"],
            text=True,
            cwd=root,
        )
    except subprocess.CalledProcessError:
        return []
    return [root / line.strip() for line in out.splitlines() if line.strip()]


def repo_files():
    result = []
    for current_root, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in skip_dirs]
        for filename in files:
            path = Path(current_root) / filename
            if path.suffix.lower() in skip_ext:
                continue
            result.append(path)
    return result


if mode == "staged":
    files = [p for p in staged_files() if p.exists()]
else:
    files = repo_files()

findings = []

for path in files:
    rel = path.relative_to(root)
    if any(part in skip_dirs for part in rel.parts):
        continue
    if path.suffix.lower() in skip_ext or is_binary(path):
        continue
    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            content = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
    except OSError:
        continue

    if any(marker in content for marker in allow_markers):
        allowed_lines = {
            idx + 1
            for idx, line in enumerate(content.splitlines())
            if any(marker in line for marker in allow_markers)
        }
    else:
        allowed_lines = set()

    for name, pattern in block_patterns:
        if pattern.search(content):
            findings.append((str(rel), 1, name, "检测到私钥块"))

    for idx, line in enumerate(content.splitlines(), start=1):
        if idx in allowed_lines:
            continue
        if any(marker in line for marker in allow_markers):
            continue
        for name, pattern in line_patterns:
            if pattern.search(line):
                findings.append((str(rel), idx, name, line.strip()[:160]))

if findings:
    print("发现疑似秘钥或敏感凭据，请先处理再提交：")
    for file, line, name, snippet in findings:
        print(f"- {file}:{line} [{name}] {snippet}")
    sys.exit(1)

print("秘钥扫描通过。")
PY
