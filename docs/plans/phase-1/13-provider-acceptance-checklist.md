# 13 Provider 手工验收留痕清单

## 1. 目标
- 固化 Google/GitHub/Apple 登录手工验收步骤与判定标准。
- 统一截图、日志与失败复盘留痕口径，作为发布审核材料。

## 2. 执行前准备
- 构建版本：记录 `build number`、分支、提交哈希。
- 运行环境：记录设备型号、iOS 版本、网络环境（Wi-Fi/4G/5G）。
- 配置确认：
  - Supabase 回调地址：`arapp://auth/callback`
  - `ARAPP_RUNTIME_MODE=staging`
  - `ARAPP_SUPABASE_URL`、`ARAPP_SUPABASE_ANON_KEY` 已正确注入

## 3. 留痕目录约定
- 建议目录：`tmp/provider-acceptance/YYYY-MM-DD/`
- 每个 Provider 至少保留：
  - 成功流程截图（进入 provider、授权页、回到 App 登录态）
  - 失败流程截图（取消授权或拒绝授权）
  - 应用日志摘要（关键时间点、错误信息）

## 4. Provider 验收矩阵

| 用例 ID | Provider | 场景 | 预期 | 结果 | 留痕文件 |
| --- | --- | --- | --- | --- | --- |
| AUTH-PROV-001 | Google | 成功授权登录 | 回到 App，Profile 显示已登录 provider | 待执行 | 待补 |
| AUTH-PROV-002 | Google | 用户取消授权 | App 提示可见，保持匿名态可继续使用 | 待执行 | 待补 |
| AUTH-PROV-003 | GitHub | 成功授权登录 | 回到 App，Profile 显示已登录 provider | 待执行 | 待补 |
| AUTH-PROV-004 | GitHub | 用户取消授权 | App 提示可见，保持匿名态可继续使用 | 待执行 | 待补 |
| AUTH-PROV-005 | Apple | 成功授权登录 | 回到 App，Profile 显示已登录 provider | 待执行 | 待补 |
| AUTH-PROV-006 | Apple | 用户取消授权 | App 提示可见，保持匿名态可继续使用 | 待执行 | 待补 |

## 5. 通用执行步骤（每个 Provider）
1. 冷启动 App，进入 Profile。
2. 点击对应 Provider 登录按钮，进入外部授权页面。
3. 完成授权或取消授权。
4. 回到 App，观察登录态与错误提示。
5. 截图并记录实际行为是否符合预期。

## 6. 通过标准
- 三方 Provider 各至少 1 次成功登录。
- 三方 Provider 的取消流程都能给出可见提示且不阻断匿名主流程。
- 无崩溃、无无法恢复的卡死状态。

## 7. 失败记录模板
- 用例 ID：
- 设备与系统版本：
- 时间：
- 实际结果：
- 期望结果：
- 日志关键片段：
- 初步定位：
- 是否阻断发布（是/否）：
