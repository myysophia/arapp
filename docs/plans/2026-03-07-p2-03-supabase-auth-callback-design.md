# P2-03 设计：Supabase Auth 回调路径与错误降级

## 1. 目标
- 固化 OAuth 回调地址约束，避免 P2-04 接入时因 scheme/host/path 不一致导致回调丢失。
- 固化错误分类口径，保证登录失败不阻断匿名主流程。
- 明确真实接入前置条件，避免未准备好就引入 SDK。

## 2. 回调地址契约
- 回调 URL 统一格式：
  - `ARAPP_SUPABASE_REDIRECT_SCHEME://ARAPP_SUPABASE_REDIRECT_HOSTARAPP_SUPABASE_REDIRECT_PATH`
  - 示例：`arapp://auth/callback`
- 配置键：
  - `ARAPP_SUPABASE_REDIRECT_SCHEME`（必填）
  - `ARAPP_SUPABASE_REDIRECT_HOST`（可选，默认 `auth`）
  - `ARAPP_SUPABASE_REDIRECT_PATH`（可选，默认 `/callback`）
- `Info.plist` 约束：
  - `CFBundleURLTypes` 必须注册 `$(ARAPP_SUPABASE_REDIRECT_SCHEME)`。
  - `Info.plist` 必须暴露 `ARAPP_SUPABASE_REDIRECT_SCHEME/HOST/PATH`，供 `AppEnvironment` 回读。

## 3. 认证链路（P2-03 口径）
1. 用户在 Login/Profile 点击 Provider。
2. `SupabaseAuthService` 发起 OAuth（P2-04 才接真实 SDK）。
3. 系统通过自定义 URL Scheme 回调 App。
4. 回调解析器按 `scheme + host + path` 校验来源。
5. 解析 `code` 或 `error`，输出统一结果：
  - `authorizationCode(code)`
  - `cancelled`
  - `providerFailure(code, description)`
6. 后续 P2-05 再把 `code/session` 交换成业务会话并刷新 UI 状态。

## 4. 错误分类与降级策略
- `invalidCallback`：
  - 场景：scheme/host/path 不匹配、缺少 `code/error`。
  - 降级：提示认证回调无效，保留匿名态，不阻断核心页面。
- `cancelled`：
  - 场景：Provider 回传 `access_denied/cancelled`。
  - 降级：提示用户取消登录，返回登录页，可重试或匿名继续。
- `providerFailure`：
  - 场景：Provider/网络侧错误（如 `server_error`）。
  - 降级：提示临时失败，建议稍后重试，保留匿名态。

## 5. 前置条件（进入 P2-04 前）
- Supabase Dashboard 已配置 iOS 重定向地址，与本地 scheme/host/path 一致。
- Xcode 构建配置存在 `ARAPP_SUPABASE_REDIRECT_SCHEME/HOST/PATH` 默认值。
- 不引入任何新第三方前，先与用户确认安装动作。

## 6. 本次产物
- 代码壳层：
  - `SupabaseAuthConfiguration` 增加 `redirectHost/redirectPath`。
  - 新增 `SupabaseAuthCallbackParser` 统一解析 query/fragment 回调参数。
  - `Info.plist + project.yml + AppEnvironment` 对齐回调配置键。
- 测试：
  - 新增回调解析测试，覆盖成功、取消、Provider 失败、无效回调。
  - 环境解析测试补充 `redirectHost/redirectPath` 默认值覆盖。
