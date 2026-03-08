# Phase 2 交付记录（2026-03-08）

## 1. 交付目标
- 记录 Phase 2（Supabase 真联调与配置治理）阶段性已交付范围、验证结果与剩余风险。

## 2. 已完成任务
- `P2-01` 建立环境配置契约与 sample 配置文件。
- `P2-02` 建立运行模式切换与依赖注入装配。
- `P2-03` 梳理 Supabase Auth 接入设计与回调路径。
- `P2-04` 接入真实 Supabase AuthService。
- `P2-05` 完成 Auth 会话交换与 Profile/Login 接线。
- `P2-10` 联调测试与发布文档收口。

## 3. 本次核心产出
- Auth 真实化：
  - `supabase-swift(Auth)` 已接入。
  - `SupabaseAuthService` 支持 `currentSession/signIn/signOut/exchangeSession`。
- 回调链路接线：
  - `AppRootView.onOpenURL -> AuthFlowModel.handleOAuthCallback -> SupabaseAuthService.exchangeSession`。
  - 登录成功后自动回到主栈并聚焦 Profile；失败可见错误且匿名兜底。
- 测试补强：
  - 新增 `AuthFlowModelTests`，覆盖 callback 成功/忽略/失败路径。
- 文档收口：
  - 测试验收计划补充 Phase 2 联调快照。
  - 发布 runbook 补充 Phase 2 发布就绪清单。

## 4. 验证结果
- `bash scripts/test-ios.sh`：通过
  - 单元测试：25/25
  - UI 冒烟：1/1
- `bash scripts/ci-local.sh`：通过
  - 秘钥扫描通过
  - 文档一致性通过
  - UI 原型冒烟通过
  - iOS 构建与测试通过

## 5. 关键配置口径
- Supabase 项目：`https://zlcnljlbuimlzhwpyrlj.supabase.co`
- 回调地址：`arapp://auth/callback`
- 本地密钥文件：`App/Environment/AppEnvironment.local.env`（已忽略，不入库）

## 6. 遗留风险与后续建议
- 真实 Provider 登录（Google/GitHub/Apple）仍需逐项手工验收留痕。
- 业务 `auth/exchange` 后端契约若启用，需补客户端端到端测试。
- RLS 越权自动化仍为发布阻断项，建议并入下一阶段优先处理。

## 7. Linear 对齐
- 项目：`arapp Phase 2`
- 本次收口状态：
  - `NIN-33`（P2-04）`Done`
  - `NIN-34`（P2-05）`Done`
  - `NIN-32`（P2-10）`Done`（已完成评论回执）
