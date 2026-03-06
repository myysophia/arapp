# GitHub 自动化接入说明

## 目标
在本仓库中启用以下自动化能力：

1. 本地 `pre-push` 门禁
2. GitHub Actions 持续集成
3. 秘钥扫描
4. 阶段标签与 Release 自动化

## 已提供的文件

1. `/Users/ninesun/projects/arapp/scripts/ci-local.sh`
2. `/Users/ninesun/projects/arapp/scripts/check-secrets.sh`
3. `/Users/ninesun/projects/arapp/scripts/check-doc-consistency.sh`
4. `/Users/ninesun/projects/arapp/scripts/test-ui-smoke.sh`
5. `/Users/ninesun/projects/arapp/scripts/test-ios.sh`
6. `/Users/ninesun/projects/arapp/scripts/install-hooks.sh`
7. `/Users/ninesun/projects/arapp/.githooks/pre-push`
8. `/Users/ninesun/projects/arapp/.github/workflows/ci.yml`
9. `/Users/ninesun/projects/arapp/.github/workflows/release-phase.yml`

## 你还需要手动完成的步骤

### 1. 初始化 Git 仓库并连接 GitHub

```bash
cd /Users/ninesun/projects/arapp
git init
git branch -M main
git remote add origin <你的仓库地址>
```

### 2. 启用版本化 hook

```bash
cd /Users/ninesun/projects/arapp
bash scripts/install-hooks.sh
```

### 3. 提交并推送

```bash
git add .
git commit -m "chore: bootstrap ci and security checks"
git push -u origin main
```

## GitHub 仓库设置建议

### 分支保护
对 `main` 启用：

1. 禁止直接推送
2. Require a pull request before merging
3. Require status checks to pass before merging
4. Require branches to be up to date before merging
5. Allow auto-merge

### 需要勾选为 Required 的检查

1. `Secrets Scan`
2. `Docs & Prototype`
3. `iOS Build & Test`

## 秘钥扫描说明

### 本地
本地 `pre-push` 和 `ci-local.sh` 会执行：

```bash
bash scripts/check-secrets.sh
```

### GitHub
CI 中额外执行：

1. `gitleaks/gitleaks-action@v2`
2. 本地 fallback 扫描脚本

如果仓库归属 GitHub 组织账号，`gitleaks-action v2` 可能需要额外配置 `GITLEAKS_LICENSE`。个人账号通常不需要。

## iOS 测试说明

当前仓库还没有实际 iOS 工程，所以：

1. `scripts/test-ios.sh` 在无工程时会自动跳过
2. 等你接入 `.xcodeproj` 或 `.xcworkspace` 后，CI 会自动开始跑构建与测试

如果脚本无法自动识别 Scheme，可以在本地或 CI 中设置：

```bash
export IOS_SCHEME="你的 Scheme 名称"
```

## 阶段 Release 用法

当某一阶段合并到 `main` 后，可以手动触发 `Release Phase` 工作流，输入：

1. `phase_tag`: 例如 `phase-1-ui-static`
2. `phase_name`: 例如 `Phase 1 UI Static`
3. `notes`: 可选补充说明

工作流会：

1. 创建 Git Tag
2. 推送 Tag
3. 创建 GitHub Release
