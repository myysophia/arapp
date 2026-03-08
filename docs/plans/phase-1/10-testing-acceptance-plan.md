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
- RLS-001 / RLS-002：已在真实 Supabase 环境通过 A/B 账号完成越权校验，建议在 CI 持续启用 `ARAPP_RLS_REQUIRED=1` 作为强制门禁。
- API-001 / API-002：当前主要通过模型与 client 层对齐验证，尚未引入真实 contract fixture。
- I18N-002：`disclaimer.non_medical` 需要在 UI 层增加显式断言。
- UI-STATE-001 / UI-STATE-002：当前已在页面状态机实现，但还缺端到端 UI 级自动化。

## 14. Phase 2 联调测试快照（2026-03-08）
### 14.1 本次联调范围
- P2-04：真实 `SupabaseAuthService`（`currentSession/signIn/signOut`）。
- P2-05：OAuth 回调会话交换（`onOpenURL -> callback handler -> exchangeSession`）与 Profile/Login 状态联动。
- P2-06：统一真实 API 运行时配置与请求装配（`EdgeFunctionsRequestConfiguration` + `LivePollenClientFactory`）。
- P2-10：联调证据与发布文档收口。

### 14.2 执行命令与结果
- `bash scripts/test-ios.sh`
  - 单元测试：41/41 通过（含新增 `AuthFlowModelTests`、`LivePollenClientFactoryTests`、`MapScreenModelTests`、`AlertsScreenModelTests` client 路径用例）。
  - UI 冒烟：1/1 通过（`AppLaunchSmokeTests`）。
- `bash scripts/ci-local.sh`
  - 秘钥扫描通过。
  - 文档结构检查通过。
  - UI 原型冒烟通过。
  - iOS 构建与测试通过。

### 14.3 新增回归点
- AUTH-CB-001：合法 OAuth 回调 URL 可完成会话交换并进入登录态。
- AUTH-CB-002：非匹配 callback URL 被忽略，不污染当前会话状态。
- AUTH-CB-003：callback 交换失败时展示错误，保持匿名兜底可继续主流程。
- API-CFG-001：Edge timeout 与 token 可通过 `AppEnvironment` 正确解析并传递到请求装配层。
- API-CFG-002：缺少 Edge base URL 时，统一抛出可识别配置错误，页面侧进入不可重试失败态。

### 14.4 仍需后续补齐
- 真实 Supabase 环境下三方 Provider（Google/GitHub/Apple）逐项手工验收截图与成功率统计（执行清单见 `docs/plans/phase-1/13-provider-acceptance-checklist.md`）。
- Edge `auth/exchange` 业务接口联调自动化已打通（函数已部署）；后续需补充网关级 JWT 校验回归（当前 `functions.v1.verify_jwt=false`）。
- RLS 越权自动化已完成真实环境验证并通过（`scripts/test-rls.py` / `scripts/test-rls.sh`）；后续重点是将 `ARAPP_RLS_REQUIRED=1` 固化到 CI/预发门禁配置。

## 15. RLS 自动化执行说明（2026-03-08）
### 15.1 执行命令
- 本地执行：`bash scripts/test-rls.sh`
- CI 执行：`bash scripts/ci-local.sh`（已接入 RLS 步骤）

### 15.2 必要环境变量
- `ARAPP_SUPABASE_URL`
- `ARAPP_SUPABASE_ANON_KEY`
- `ARAPP_RLS_USER_A_EMAIL`
- `ARAPP_RLS_USER_A_PASSWORD`
- `ARAPP_RLS_USER_B_EMAIL`
- `ARAPP_RLS_USER_B_PASSWORD`

### 15.3 可选环境变量
- `ARAPP_RLS_LOCATION_ID`：当 B 用户无 `alert_subscriptions` 时用于提供 location 兜底。
- `ARAPP_RLS_THRESHOLD_LEVEL`：写入阈值兜底，默认 `moderate`。
- `ARAPP_RLS_TIMEOUT_SECONDS`：请求超时秒数，默认 `15`。
- `ARAPP_RLS_REQUIRED`：设为 `1` 时，缺少变量将直接失败（用于强制门禁）。

### 15.4 当前行为
- 若缺少必要环境变量且未设置 `ARAPP_RLS_REQUIRED=1`，脚本输出 `SKIP` 并返回成功，避免阻塞日常开发。
- 在发布/预发门禁中建议设置 `ARAPP_RLS_REQUIRED=1`，使 RLS 校验变为强制项。

### 15.5 本次实测结果（2026-03-08）
- 测试账号：A/B 两个 Supabase 邮箱账号（真实环境）。
- 执行命令：`ARAPP_RLS_REQUIRED=1 bash scripts/test-rls.sh`
- 结果：
  - `PASS RLS-001`：A 用户读取 B 用户 `devices` 失败（符合预期）。
  - `PASS RLS-002`：A 用户写入 B 用户 `alert_subscriptions` 失败（符合预期）。
- 结论：RLS 越权自动化脚本与数据库策略闭环成立，可作为发布阻断门禁。

## 16. auth/exchange 自动化执行说明（2026-03-08）
### 16.1 执行命令
- 本地执行：`bash scripts/test-auth-exchange.sh`
- CI 执行：`bash scripts/ci-local.sh`（已接入 auth/exchange 步骤）

### 16.2 必要环境变量
- `ARAPP_SUPABASE_URL`
- `ARAPP_SUPABASE_ANON_KEY`
- `ARAPP_EDGE_BASE_URL`
- `ARAPP_AUTH_TEST_EMAIL`
- `ARAPP_AUTH_TEST_PASSWORD`

### 16.3 可选环境变量
- `ARAPP_AUTH_EXCHANGE_PATH`：默认 `/v1/auth/exchange`。
- `ARAPP_AUTH_EXCHANGE_METHOD`：默认 `POST`。
- `ARAPP_AUTH_EXCHANGE_BODY_JSON`：请求体 JSON 字符串，默认 `{}`。
- `ARAPP_AUTH_EXCHANGE_TIMEOUT_SECONDS`：请求超时秒数，默认 `15`。
- `ARAPP_AUTH_EXCHANGE_REQUIRED`：设为 `1` 时，缺少变量或请求失败直接返回非 0。

### 16.4 当前行为
- 若缺少必要环境变量且未设置 `ARAPP_AUTH_EXCHANGE_REQUIRED=1`，脚本输出 `SKIP` 并返回成功，避免阻塞日常开发。
- 在预发/发布门禁建议设置 `ARAPP_AUTH_EXCHANGE_REQUIRED=1`，并配合后端端点部署状态启用强制阻断。

### 16.5 本次实测结果（2026-03-08）
- 测试账号：`test1@agentgo.tech`
- 执行：
  - 非强制：`bash scripts/test-auth-exchange.sh`
  - 强制：`ARAPP_AUTH_EXCHANGE_REQUIRED=1 bash scripts/test-auth-exchange.sh`
- 环境：`ARAPP_EDGE_BASE_URL=https://zlcnljlbuimlzhwpyrlj.supabase.co/functions/v1`
- 结果：
  - 非强制模式：`HTTP 404 NOT_FOUND` 时按预期输出 `SKIP` 并返回成功。
  - 强制模式：同样场景返回非 0 并阻断（符合门禁语义）。
- 结论：脚本行为符合设计；当前阻塞点是后端 `auth/exchange` 函数尚未部署。

### 16.6 部署后复测结果（2026-03-08）
- 动作：
  - 已部署 Edge Function `v1`，并承载路径 `/v1/auth/exchange`。
  - 执行：`ARAPP_AUTH_EXCHANGE_REQUIRED=1 bash scripts/test-auth-exchange.sh`
- 环境：
  - `ARAPP_EDGE_BASE_URL=https://zlcnljlbuimlzhwpyrlj.supabase.co/functions/v1`
  - 测试账号：`test1@agentgo.tech`
- 结果：
  - `PASS AUTH-EXCHANGE-001`：`/v1/auth/exchange` 返回 2xx，且包含 `request_id/code/message/retryable`。
- 结论：
  - `auth/exchange` 自动化门禁已从“端点未部署”转为“可强制通过”。
  - 当前配置采用 `functions.v1.verify_jwt=false`，后续需安排安全回归恢复网关级 JWT 校验。
