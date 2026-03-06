# NIN-10 / T06 开工说明

## 任务
- 建立测试骨架与基线校验

## 输出物
- 单元测试 target
- UI 测试 target
- 至少 1 个冒烟测试

## 目录边界
- 仅允许修改：
  - `Tests/`
  - `UITests/`
  - 与测试相关的项目配置文件

## 禁止项
- 不实现业务页面
- 不修改设计 Token
- 不接入真实服务

## 依赖策略
- 该任务依赖 `T03`
- 若 `T03` 未完成，可先准备：
  - 测试目录结构
  - 命名约定
  - 基础断言模板
  - CI 接线说明

## 完成标准
- 测试 target 可运行
- 至少有 1 个通过的 smoke test
- 能为后续页面和组件测试提供基础结构

## 参考
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/10-testing-acceptance-plan.md`
- `/Users/ninesun/projects/arapp/scripts/test-ios.sh`

## 分支
- `codex/nin-10-test-baseline`
