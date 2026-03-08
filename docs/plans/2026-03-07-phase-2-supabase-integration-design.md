# Phase 2 设计：Supabase 真联调与配置治理

## 1. 目标与成功标准
- 目标：在 Phase 1 的静态骨架、Mock 数据和测试基线之上，完成真实 Supabase Auth、Edge Functions API、配置治理和联调收口。
- 成功标准：应用可以在不改代码的前提下切换 Mock 模式与真实环境；登录、读取风险摘要、读取趋势、读取来源说明、保存提醒订阅能够打通到真实后端；配置和密钥不会硬编码进仓库。
- 本阶段默认不新增未获批准的第三方安装；如需新增 SDK 或 CLI，单独停下来确认。

## 2. 范围与非范围
### 范围
- 环境配置契约：Supabase URL、anon key、redirect scheme、API base URL、运行模式。
- iOS 配置层：`AppEnvironment`、`BuildConfiguration`、本地 `.xcconfig` 或等价安全注入机制。
- Auth 联调：`AuthServicing` 从 Mock 过渡到真实 `SupabaseAuthService`。
- API 联调：`PollenAPIClienting` 从 Mock 过渡到真实 `EdgeFunctionsPollenAPIClient`。
- 页面接线：Today / Map / Alerts / Profile / Login 的真实数据模式。
- 测试补强：环境解析、错误映射、集成冒烟。
- 发布准备：联调 checklist、密钥管理说明、PR/CI 约束。

### 非范围
- 付费、广告、B2B。
- 复杂离线同步。
- 推送生产证书与正式 APNs 发布。
- 数据库新 schema 大改；如需改动，以 Phase 1 的 `05-db-schema-supabase.sql.md` 为基线增量处理。

## 3. 方案对比与结论
### 方案 A：直接在页面层接入 Supabase 与 HTTP
- 优点：短期接线快。
- 缺点：页面耦合 Supabase/HTTP 细节，后续测试和替换成本高。

### 方案 B：保留协议边界，先补环境层，再接真实实现
- 优点：与 Phase 1 结构一致，Mock/真实双模式切换成本低，测试面更稳定。
- 缺点：需要先补一层配置与装配代码，前期稍慢。

### 方案 C：先只做配置文档，不动代码
- 优点：零风险。
- 缺点：对真实联调推进价值有限。

### 推荐
- 采用方案 B。
- 理由：当前已有 `AuthServicing` 与 `PollenAPIClienting` 协议边界，继续保持分层最合理；先把环境和注入机制做好，再逐个页面切到真实实现，风险最低。

## 4. 架构与任务分层
### 配置层
- 新增环境模型：区分 `mock`、`staging`、`production`。
- 所有 URL、key、scheme 从配置层读取，不散落在页面或 service 内。
- 默认仓库只保留 `sample` 配置，不提交真实密钥。

### 服务层
- `AuthServicing`
  - Phase 2 目标：读取当前 session、触发 Provider 登录、处理登出。
  - 继续保持 Mock 实现与真实实现并存。
- `PollenAPIClienting`
  - Phase 2 目标：接真实 `summary / forecast / sources / suggestions / alerts`。
  - 页面不直接依赖 URLSession。

### 页面层
- Today：支持加载、成功、失败、陈旧缓存态。
- Map：支持搜索建议、来源说明、抽屉数据填充。
- Alerts：支持真实订阅保存与回显。
- Profile / Login：支持读取 session 和 provider 状态。

## 5. 里程碑拆分
### M1：配置契约与运行模式
- 产出：环境配置文档、配置文件模板、运行模式切换入口、sample 配置。
- 风险：密钥误入库。
- 验收：仓库内无真实密钥，切换 mock/real 不需要改业务代码。

### M2：Auth 真实接入
- 产出：真实 `SupabaseAuthService`、回调处理、Profile 页会话展示。
- 风险：需要新增 iOS SDK；如需新增依赖，先征得确认。
- 验收：至少一种 provider 能走通到 session 获取。

### M3：API 真实联调
- 产出：Today / Map / Alerts 切到真实后端。
- 风险：后端契约偏差、CORS/鉴权问题。
- 验收：核心接口成功率达标，错误映射可见。

### M4：测试与发布准备
- 产出：联调测试、CI 增补、配置说明、交付记录。
- 验收：本地 CI 通过，关键真实链路有可复现步骤。

## 6. Phase 2 Linear 任务建议
1. P2-01 建立环境配置契约与 sample 配置文件
2. P2-02 建立运行模式切换与依赖注入装配
3. P2-03 梳理 Supabase Auth 接入设计与回调路径
4. P2-04 接入真实 Supabase AuthService
5. P2-05 完成 Auth 会话交换与 Profile/Login 接线
6. P2-06 建立真实 API 配置与请求装配
7. P2-07 Today 接入真实 summary/forecast
8. P2-08 Map 接入真实 suggestions/sources
9. P2-09 Alerts 接入真实 subscriptions
10. P2-10 补齐联调测试与发布文档

### 6.1 Linear 当前落地（基于 session `019cb92e-13f2-7a82-8c5d-aff9c4113e74`）
- 已创建项目：`arapp Phase 2`（`https://linear.app/ninesun/project/arapp-phase-2-e4451c97f36b`）
- 已确认创建的任务：
  - `NIN-29`：P2-01 建立环境配置契约与 sample 配置文件
  - `NIN-30`：P2-02 建立运行模式切换与依赖注入装配
  - `NIN-31`：P2-03 梳理 Supabase Auth 接入设计与回调路径
  - `NIN-33`：P2-04 接入真实 Supabase AuthService
  - `NIN-34`：P2-05 完成 Auth 会话交换与 Profile/Login 接线
  - `NIN-32`：P2-10 联调测试与发布文档收口
- 备注：`NIN-32`、`NIN-33`、`NIN-34` 已在本次会话完成并通过本地门禁验证。

## 7. 首个立即启动任务
- 任务：P2-01 建立环境配置契约与 sample 配置文件。
- 原因：不依赖 Supabase 凭据，不需要新增 SDK，不阻塞后续所有真实联调任务。
- 产出：
  - `App/Environment/` 目录与环境模型
  - 示例配置模板
  - 文档：本地如何提供密钥、哪些文件不能提交

## 8. 风险与约束
- 新增 Supabase iOS SDK 或其他依赖前，必须先征得确认。
- 不删除任何不确定归属的文件或目录。
- 真实密钥只允许存在于本地未跟踪配置文件、Keychain 或 CI Secret。
- 网络联调会受你本地环境和 Supabase 项目状态影响，默认保留 Mock 回退能力。

## 9. 验收口径
- Linear 项目、里程碑、任务已创建。
- `P2-01` 到 `P2-05` 与 `P2-10` 已落地，`NIN-32`、`NIN-33`、`NIN-34` 状态已更新为 `Done`。
- 本地 kickoff 文档已提交到 `codex/phase2-kickoff`。
- 未引入未经确认的新第三方安装。

## 10. 执行进度（更新至 2026-03-08）
- `P2-01` 已完成：环境配置契约、sample 配置模板、本地安全边界、统一配置读取入口已落地。
- `P2-02` 已完成：`AppDependencies -> AppState -> AppRootView` 统一装配链路已建立，页面不再各自拼装依赖。
- `P2-03` 已完成：回调路径契约、`Info.plist` scheme 约束、错误分类与降级策略已固化，详见 `docs/plans/2026-03-07-p2-03-supabase-auth-callback-design.md`。
- `P2-04` 已完成：`supabase-swift(Auth)` 依赖接入、`SupabaseAuthService` 真实 `session/signIn/signOut` 实现、`exchangeSession(fromCallbackURL:)` 回调桥接方法已落地。
- `P2-05` 已完成：`AppRootView.onOpenURL -> AuthFlowModel.handleOAuthCallback -> SupabaseAuthService.exchangeSession` 链路已打通；Profile/Login 状态联动已接线。
- `P2-10` 已完成：联调测试快照、发布就绪清单、Phase 2 交付记录已归档（`10-testing-acceptance-plan.md`、`11-release-observability-runbook.md`、`2026-03-08-phase-2-delivery-record.md`）。
- 验证结果：`bash scripts/test-ios.sh` 与 `bash scripts/ci-local.sh` 全部通过（25 单测 + 1 UI 冒烟 + 本地门禁）。
