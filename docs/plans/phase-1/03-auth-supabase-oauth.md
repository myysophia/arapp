# 03 认证设计（Supabase OAuth）

## 1. 目标与成功标准
- 目标：实现“匿名先用、登录可选”，支持 Google/GitHub/Apple 登录。
- 成功标准：登录成功率 >= 97%，失败不阻断匿名主流程。

## 2. 范围与非范围
- 范围：Supabase Auth 配置、账户绑定、会话策略、登出流程。
- 非范围：邮箱密码登录、企业 SSO、多因子认证。

## 3. 输入/输出与接口
- 输入：用户点击 Provider、OAuth 回调结果。
- 输出：`auth_user_id`、会话 token、登录状态。
- 接口：`POST /v1/auth/exchange`、`GET /v1/auth/me`、`POST /v1/auth/logout`。

## 4. 数据模型与约束
- 主身份：`auth.users.id`。
- 扩展表：`profiles.user_id`、`user_preferences.user_id`。
- 设备绑定：`devices.user_id + device_id` 唯一。

## 5. 异常与降级
- OAuth 取消：提示可稍后登录，回到原流程。
- token 过期：静默刷新失败后要求重新登录。
- Provider 不可用：展示备用登录选项。

## 6. 安全与合规
- 客户端不保存 service key。
- 会话 token 使用安全存储（Keychain）。
- 记录最小审计字段，不记录第三方敏感凭据。

## 7. 埋点与可观测性
- `auth_start(provider)`、`auth_success(provider)`、`auth_fail(provider,reason)`。
- 监控维度：登录成功率、取消率、回调超时率。

## 8. 测试与验收
- 三方登录均可用。
- 匿名用户升级为登录用户后保留本地偏好。
- 退出登录后回退匿名态且功能可用。

## 9. 依赖与里程碑
- 依赖：Supabase 项目、Apple Developer 配置、回调域名。
- 里程碑：第 3-4 周完成三方登录联调。

## 10. 假设与默认值
- 首版只支持 OAuth Provider 登录。
- 默认登录入口位于“我的”页面。

## 流程摘要
1. 用户点击 Provider。
2. 客户端完成 OAuth。
3. 获取 Supabase session。
4. 调用 `/v1/auth/exchange` 完成业务会话交换。
5. 初始化 `profiles` 与 `user_preferences`。
