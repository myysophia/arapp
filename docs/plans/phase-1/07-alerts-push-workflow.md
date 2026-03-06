# 07 提醒与推送工作流

## 1. 目标与成功标准
- 目标：建立稳定的高花粉阈值提醒流程。
- 成功标准：提醒发送成功率 >= 95%，重复提醒率可控。

## 2. 范围与非范围
- 范围：阈值设置、静默时段、APNs 推送、事件记录。
- 非范围：营销推送、复杂个性化推荐推送。

## 3. 输入/输出与接口
- 输入：`alert_subscriptions`、`devices`、`pollen_daily_cache`。
- 输出：推送消息与 `notification_events` 记录。
- 接口：`POST /v1/alerts/subscriptions`。

## 4. 数据模型与约束
- 关键字段：`user_id`、`device_id`、`location_id`、`threshold_level`、`enabled`。
- 去重键：`user_id + location_id + target_date`。
- 状态：`queued/sent/failed/skipped`。

## 5. 异常与降级
- token 失效：标记设备 `is_active=false`，停止推送。
- APNs 失败：指数退避重试，超过阈值记 `failed`。
- 数据缺失：跳过并记录 `skipped`。

## 6. 安全与合规
- 推送内容不包含具体医疗诊断。
- 推送仅发送必要摘要，不携带敏感原始数据。

## 7. 埋点与可观测性
- 埋点：`alert_evaluated`、`alert_sent`、`alert_failed`。
- 指标：发送成功率、重试率、去重率。

## 8. 测试与验收
- 阈值边界测试（0/5）。
- 静默时段测试。
- 设备失效与重试链路测试。

## 9. 依赖与里程碑
- 依赖：APNs 证书、设备 token 上报、缓存数据可用。
- 里程碑：第 7 周完成端到端联调。

## 10. 假设与默认值
- 每日默认检测窗口：07:00。
- 当日同城市默认最多 1 次提醒。
