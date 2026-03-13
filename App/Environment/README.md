# App Environment 配置说明

## 目标
- 统一 `mock / staging / production` 运行模式。
- 统一读取 Edge Functions 与 Supabase 的配置来源。
- 确保真实密钥不进入仓库。

## 配置键
- `ARAPP_RUNTIME_MODE`：`mock` / `staging` / `production`。
- `ARAPP_EDGE_BASE_URL`：Edge Functions API 基础地址。
- `ARAPP_EDGE_TIMEOUT_SECONDS`：Edge API 请求超时秒数（默认 `15`）。
- `ARAPP_ACCESS_TOKEN`：联调时的访问令牌（可选）。
- `ARAPP_SUPABASE_URL`：Supabase 项目 URL。
- `ARAPP_SUPABASE_ANON_KEY`：Supabase anon key。
- `ARAPP_SUPABASE_REDIRECT_SCHEME`：OAuth 回调 scheme。
- `ARAPP_SUPABASE_REDIRECT_HOST`：OAuth 回调 host（默认 `auth`）。
- `ARAPP_SUPABASE_REDIRECT_PATH`：OAuth 回调 path（默认 `/callback`）。

## 本地使用
1. 复制 `AppEnvironment.sample.env` 为 `AppEnvironment.local.env`。
2. 在本机填写真实值，不要提交到 Git。
3. 将需要的键注入到 Xcode Scheme Environment Variables 或本地脚本环境。

### 推荐回调地址格式
- `ARAPP_SUPABASE_REDIRECT_SCHEME://ARAPP_SUPABASE_REDIRECT_HOSTARAPP_SUPABASE_REDIRECT_PATH`
- 示例：`arapp://auth/callback`

## 安全边界
- `AppEnvironment.local.env` 与 `AppEnvironment.local.xcconfig` 已加入 `.gitignore`。
- 仓库只保留 sample 模板，不保留真实密钥。
