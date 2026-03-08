# 11 发布与可观测性 Runbook

## 1. 目标与成功标准
- 目标：定义从灰度到发布的标准操作流程与故障应对流程。
- 成功标准：发布可回滚、异常可告警、问题可追踪。

## 2. 范围与非范围
- 范围：发布步骤、监控告警、故障分级、回滚流程、值班机制。
- 非范围：企业级 7x24 NOC 体系。

## 3. 输入/输出与接口
- 输入：测试报告、版本构建、配置变更记录。
- 输出：发布记录、告警记录、复盘报告。
- 接口：依赖 Edge Functions、Supabase 日志与 APNs 发送结果。

## 4. 数据模型与约束
- 发布记录字段：`version`、`release_time`、`operator`、`change_scope`。
- 告警字段：`metric`、`threshold`、`current_value`、`severity`。

## 5. 异常与降级
- API 错误率异常：降级读缓存。
- 推送失败率异常：暂停批量推送并切重试策略。
- 登录异常：保留匿名主流程并临时隐藏登录入口。

## 6. 安全与合规
- 发布前执行权限检查与密钥检查。
- 回滚时确保不泄露日志敏感信息。

## 7. 埋点与可观测性
- 关键指标：
  - API 成功率
  - P95 延迟
  - 缓存命中率
  - 推送成功率
  - 崩溃率
- 告警阈值：
  - API 成功率 < 99%
  - 推送成功率 < 95%
  - 崩溃率 >= 1%

## 8. 测试与验收
- 预发布演练：一次完整发布+一次完整回滚。
- 告警演练：模拟 API 失败和推送失败。

## 9. 依赖与里程碑
- 依赖：测试验收通过、监控接入、告警通道可用。
- 里程碑：第 10 周完成 Runbook 演练。

## 10. 假设与默认值
- 首版由单人值班，严重故障 30 分钟内响应。
- 所有关键告警默认推送到统一通知通道。

## 11. Phase 2 发布就绪清单（2026-03-08）
### 11.1 配置与密钥
- `App/Environment/AppEnvironment.local.env` 已配置：
  - `ARAPP_RUNTIME_MODE=staging`
  - `ARAPP_SUPABASE_URL`
  - `ARAPP_SUPABASE_ANON_KEY`
  - `ARAPP_SUPABASE_REDIRECT_SCHEME/HOST/PATH`
- 本地真实密钥文件已在 `.gitignore` 忽略，未入库。
- Supabase Dashboard 已配置回调地址：`arapp://auth/callback`。

### 11.2 联调验证门禁
- 必跑：`bash scripts/test-ios.sh`
- 必跑：`bash scripts/ci-local.sh`
- 通过标准：
  - 单元测试与 UI 冒烟全绿。
  - 秘钥扫描与文档一致性检查全绿。

### 11.3 上线前人工检查
- 登录链路：Google/GitHub/Apple 至少各 1 次全流程成功。
- 失败链路：取消登录、回调错误、会话缺失均有可见提示且可回到匿名态。
- 观察项：`auth_success`、`auth_fail`、API 成功率、崩溃率。

### 11.4 回滚策略（Auth 相关）
- 如发布后出现大面积登录失败：
  - 将 `ARAPP_RUNTIME_MODE` 暂切 `mock` 或下发开关隐藏登录入口。
  - 保留匿名主流程可用，避免阻断 Today/Map/Alerts 核心路径。
  - 在 Linear 创建事故记录并回填复盘。
