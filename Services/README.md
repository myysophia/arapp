# Services

当前目录承接 Phase 2 服务接线，包含两类核心能力：

- Auth：`AuthServicing` 与 `SupabaseAuthService`（真实会话、OAuth 登录、登出、回调会话交换）。
- API：`PollenAPIClienting`、`EdgeFunctionsPollenAPIClient`、`LivePollenClientFactory`。

## API 装配口径（P2-06）
- 运行时配置统一由 `AppEnvironment` 解析，来源于环境变量与 `Info.plist`。
- `LivePollenClientFactory` 负责把环境配置映射为请求配置（base URL、token、timeout、默认头）。
- 页面层（Today/Map/Alerts）通过统一工厂创建 live client，不再各自拼装网络参数。
