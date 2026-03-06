# Wave 0 并行执行说明

## 目标
- 为 `T03`、`T04`、`T05`、`T06` 提供可直接开工的并行执行边界。
- 让每个 Agent 在独立分支和独立工作目录中开发，避免改同一文件。

## 任务映射
1. `NIN-7 / T03`：iOS 工程骨架与目录约定
2. `NIN-8 / T04`：设计 Token 到 SwiftUI 的映射
3. `NIN-9 / T05`：领域模型与 Mock 数据
4. `NIN-10 / T06`：测试骨架与基线校验

## 执行顺序
1. 先创建 4 个 worktree。
2. 每个 Agent 只在自己的 worktree 内工作。
3. 每个 Agent 完成后独立提交并推送。
4. `T06` 依赖 `T03`，但可以先完成测试目录和占位设计，等 `T03` 合入后补齐运行。

## 统一规则
- 基线分支：`main`
- 分支前缀：`codex/`
- 每个分支只服务一个 Linear issue
- 只允许修改任务边界内的目录和文件
- 提交前必须运行：
  - `bash scripts/ci-local.sh`

## 推荐 worktree 目录
- `/Users/ninesun/projects/arapp-worktrees/nin-7-ios-scaffold`
- `/Users/ninesun/projects/arapp-worktrees/nin-8-design-tokens`
- `/Users/ninesun/projects/arapp-worktrees/nin-9-models-mocks`
- `/Users/ninesun/projects/arapp-worktrees/nin-10-test-baseline`

## 共享真源
- Figma 真源：`cf5PnK1WSe5IYRQNGT81fu`
- UI 文档真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`
- 数据库真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/05-db-schema-supabase.sql.md`
- API 真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/06-api-edge-functions-contract.md`

## 开工方式
- 运行：

```bash
bash /Users/ninesun/projects/arapp/scripts/setup-wave0-worktrees.sh
```

- 然后把对应 Agent 指向对应 worktree，并附上本目录下的任务说明文件。
