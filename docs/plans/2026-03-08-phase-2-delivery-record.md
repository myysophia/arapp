# Phase 2 交付记录（2026-03-08）

## 1. 交付目标
- 记录 Phase 2（Supabase 真联调与配置治理）阶段性已交付范围、验证结果与剩余风险。

## 2. 已完成任务
- `P2-01` 建立环境配置契约与 sample 配置文件。
- `P2-02` 建立运行模式切换与依赖注入装配。
- `P2-03` 梳理 Supabase Auth 接入设计与回调路径。
- `P2-04` 接入真实 Supabase AuthService。
- `P2-05` 完成 Auth 会话交换与 Profile/Login 接线。
- `P2-06` 建立真实 API 配置与请求装配。
- `P2-07` Today 接入真实 summary/forecast。
- `P2-08` Map 接入真实 suggestions/sources。
- `P2-09` Alerts 接入真实 subscriptions。
- `P2-10` 联调测试与发布文档收口。
- `P2-11` RLS 越权自动化脚本与执行入口。
- `P2-12` Provider 手工验收留痕模板与发布清单。
- `P2-13` `auth/exchange` 联调自动化脚本与 CI 可选入口。
- `P2-14` 部署 `auth/exchange` Edge Function 并完成强制门禁验证。

## 3. 本次核心产出
- Auth 真实化：
  - `supabase-swift(Auth)` 已接入。
  - `SupabaseAuthService` 支持 `currentSession/signIn/signOut/exchangeSession`。
- 回调链路接线：
  - `AppRootView.onOpenURL -> AuthFlowModel.handleOAuthCallback -> SupabaseAuthService.exchangeSession`。
  - 登录成功后自动回到主栈并聚焦 Profile；失败可见错误且匿名兜底。
- 测试补强：
  - 新增 `AuthFlowModelTests`，覆盖 callback 成功/忽略/失败路径。
  - 新增 `LivePollenClientFactoryTests`，覆盖配置映射与缺失配置错误。
- API 装配收敛：
  - 新增 `EdgeFunctionsRequestConfiguration`，统一 `baseURL/token/timeout/defaultHeaders`。
  - 新增 `LivePollenClientFactory`，统一 live API client 构造入口。
  - Today/Map/Alerts 改为复用统一 live client 工厂。
- Alerts 真实读写链路：
  - `AlertsScreenModel` client 模式新增 `upsertAlertSubscription` 写回，`reload/update` 失败映射统一走 `failureState(for:)`。
  - 失败态重试语义与 `APIClientError.isRetryable` 对齐，确保“错误可见且可恢复”。
  - `AlertsView` 开关/阈值交互切换为异步更新，避免 UI 与真实写回链路脱节。
- 文档收口：
  - 测试验收计划补充 Phase 2 联调快照。
  - 发布 runbook 补充 Phase 2 发布就绪清单。
  - 新增 Provider 手工验收留痕清单：`docs/plans/phase-1/13-provider-acceptance-checklist.md`。
- auth/exchange 联调门禁补齐：
  - 新增 `scripts/test-auth-exchange.py` 与 `scripts/test-auth-exchange.sh`。
  - `scripts/ci-local.sh` 接入 auth/exchange 可选步骤。
  - 测试验收计划补充 auth/exchange 环境变量与强制模式口径。
  - 已部署 Edge Function `v1`，`ARAPP_AUTH_EXCHANGE_REQUIRED=1` 强制校验通过。

## 4. 验证结果
- `bash scripts/test-ios.sh`：通过
  - 单元测试：41/41
  - UI 冒烟：1/1
- `bash scripts/ci-local.sh`：通过
  - 秘钥扫描通过
  - 文档一致性通过
  - UI 原型冒烟通过
  - iOS 构建与测试通过
- `ARAPP_AUTH_EXCHANGE_REQUIRED=1 bash scripts/test-auth-exchange.sh`：通过
  - `PASS AUTH-EXCHANGE-001`

## 5. 关键配置口径
- Supabase 项目：`https://zlcnljlbuimlzhwpyrlj.supabase.co`
- 回调地址：`arapp://auth/callback`
- 本地密钥文件：`App/Environment/AppEnvironment.local.env`（已忽略，不入库）

## 6. 遗留风险与后续建议
- 真实 Provider 登录（Google/GitHub/Apple）需按 `13-provider-acceptance-checklist.md` 执行并补齐证据文件。
- `auth/exchange` 已完成部署并通过强制门禁；当前为兼容现网 token 校验问题，`functions.v1.verify_jwt=false`。建议后续专项恢复网关级 JWT 校验并补回归。
- RLS 越权自动化脚本与最小策略迁移已在真实环境验证通过（RLS-001/RLS-002 均 PASS）；后续需持续在 CI/预发启用 `ARAPP_RLS_REQUIRED=1` 保持门禁。

## 7. Linear 对齐
- 项目：`arapp Phase 2`
- 本次收口状态：
  - `NIN-35`（P2-06）`Done`（统一 API 配置与请求装配已落地）
  - `NIN-36`（P2-07）`Done`（Today 真实 summary/forecast 已接线并通过回归）
  - `NIN-37`（P2-08）`Done`（Map 真实 suggestions/sources 已接线并通过回归）
  - `NIN-38`（P2-09）`Done`（Alerts 真实 subscriptions 读写与错误恢复语义已接线并通过回归）
  - `NIN-33`（P2-04）`Done`
  - `NIN-34`（P2-05）`Done`
  - `NIN-32`（P2-10）`Done`（已完成评论回执）
  - `NIN-39`（P2-11）`Done`（RLS 越权自动化脚本与执行入口已落地，真实环境强制校验通过）
  - `NIN-40`（P2-12）`Done`（Provider 手工验收留痕模板与发布清单已落地）
  - `NIN-41`（P2-13）`Done`（auth/exchange 联调自动化脚本与 CI 可选入口已落地）
  - `NIN-42`（P2-14）`Done`（auth/exchange Edge Function 已部署，强制门禁校验通过）
