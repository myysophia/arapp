# 10 测试与验收计划

## 1. 目标与成功标准
- 目标：建立发布前可执行测试矩阵与阻断规则。
- 成功标准：核心路径稳定、权限无越权、双语可用、关键指标达标。

## 2. 范围与非范围
- 范围：功能、接口、权限、RLS、i18n、性能、稳定性。
- 非范围：渗透测试与大规模压力测试（后续阶段）。

## 3. 输入/输出与接口
- 输入：02/03/05/06/08/09 文档定义。
- 输出：测试报告、缺陷清单、发布建议。
- 接口：全量覆盖 `06` 的 endpoint。

## 4. 数据模型与约束
- 测试数据：匿名用户、登录用户、双语用户、无权限用户。
- 约束：字段命名按 05/06 一致；风险值范围 0-5。

## 5. 异常与降级
- 无网络、上游失败、token 失效、推送失败都需有用例。
- 降级必须可见且可恢复。

## 6. 安全与合规
- RLS 越权测试为发布阻断项。
- 隐私与删除链路必须通过。

## 7. 埋点与可观测性
- 校验埋点覆盖：`view_today_risk`、`auth_success`、`switch_locale`、`alert_sent`。
- 校验监控指标：API 成功率、崩溃率、推送成功率。

## 8. 测试与验收
- 发布阻断规则：
  - P0 未关闭：禁止发布
  - P1 未关闭：禁止发布
  - API 成功率 < 99%：禁止发布
  - 崩溃率 >= 1%：禁止发布
- 重点用例矩阵：
  - RLS-001：A 用户读取 B 用户 `devices` 失败
  - RLS-002：A 用户写入 B 用户 `alert_subscriptions` 失败
  - I18N-001：`risk.level.0-5` 双语显示正确（追溯 02/08）
  - I18N-002：`disclaimer.non_medical` 双语一致（追溯 02/08）
  - API-001：`summary` 字段与 05/06 一致
  - API-002：`alerts/subscriptions` 字段与 05/06 一致
  - UI-STATE-001：离线态展示缓存时间、重试入口与正确文案（追溯 02）
  - UI-STATE-002：无定位权限时展示手动选城入口且主流程可继续（追溯 02）

## 9. 依赖与里程碑
- 依赖：数据库迁移完成、接口冻结、UI 定稿。
- 里程碑：第 9 周完成全链路回归，第 10 周完成灰度验收。

## 10. 假设与默认值
- 测试环境与生产字段完全一致。
- 自动化覆盖核心路径，手工补充体验与视觉检查。

## 11. 已落地自动化测试基线（2026-03-07）
### 11.1 当前自动化入口
- 本地统一入口：`bash scripts/ci-local.sh`
- iOS 测试入口：`bash scripts/test-ios.sh`
- 工程生成：`xcodegen generate`
- 当前每个 worktree 使用独立 `.build/DerivedData`，避免并行测试冲突。

### 11.2 当前单元测试覆盖
- `AppBootSmokeTests`
  - 校验底部 Tab 数量为 4。
- `TodayScreenModelTests`
  - 覆盖 `mock success`
  - 覆盖 `mock empty`
  - 覆盖 `client transport failure`
- `MapScreenModelTests`
  - 覆盖 `mock success`
  - 覆盖 `mock failure`
  - 覆盖搜索抽屉/来源抽屉开关
- `AlertsScreenModelTests`
  - 覆盖 `mock configured`
  - 覆盖 `mock empty`
  - 覆盖开关与阈值状态变更

### 11.3 当前 UI 冒烟测试覆盖
- `AppLaunchSmokeTests`
  - 启动应用
  - 跳过 Onboarding
  - 校验底部 Tab 出现
  - 顺序切换 `Today / Map / Alerts / Profile`
  - 测试逻辑兼容中英文按钮文案

## 12. 当前验收快照（2026-03-07）
- 本地 `ci-local.sh` 已通过。
- 当前自动化结果：
  - 单元测试：10/10 通过
  - UI 测试：1/1 通过
- 已验证问题：
  - `DerivedData` 并行冲突已通过脚本隔离修复。
  - 国际化接入后，关键页面仍可构建并通过烟测。

## 13. 后续补测缺口
- RLS-001 / RLS-002：依赖 Supabase 真实环境，当前尚未自动化落地。
- API-001 / API-002：当前主要通过模型与 client 层对齐验证，尚未引入真实 contract fixture。
- I18N-002：`disclaimer.non_medical` 需要在 UI 层增加显式断言。
- UI-STATE-001 / UI-STATE-002：当前已在页面状态机实现，但还缺端到端 UI 级自动化。
