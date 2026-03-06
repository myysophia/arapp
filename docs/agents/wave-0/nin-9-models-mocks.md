# NIN-9 / T05 开工说明

## 任务
- 建立领域模型与 Mock 数据

## 输出物
- `PollenSummary`
- `PollenForecast`
- `AlertSubscription`
- `SourceMeta`
- 可驱动 SwiftUI 预览的 fixtures

## 目录边界
- 仅允许修改：
  - `Models/`
  - `Mocks/`
  - `Fixtures/`

## 禁止项
- 不改页面布局
- 不改 UI Token
- 不接真实网络层

## 数据约束
- 字段命名必须与以下真源一致：
  - `/Users/ninesun/projects/arapp/docs/plans/phase-1/05-db-schema-supabase.sql.md`
  - `/Users/ninesun/projects/arapp/docs/plans/phase-1/06-api-edge-functions-contract.md`
- 风险等级统一 `0..5`
- `sourceType` 必须支持模型点语义

## 完成标准
- 模型字段与文档一致
- Mock 可以覆盖：
  - 正常态
  - 高风险态
  - 低信心态
  - 空提醒态
  - 登录/匿名两种偏好场景

## 参考
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/05-db-schema-supabase.sql.md`
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/06-api-edge-functions-contract.md`

## 分支
- `codex/nin-9-models-mocks`
