# 06 Edge Functions API 契约（唯一真源）

## 1. 目标与成功标准
- 目标：定义唯一对外 API 契约，保证客户端与数据库解耦。
- 成功标准：字段命名与 `05` 一致，错误码统一，可直接用于实现。

## 2. 范围与非范围
- 范围：认证、用户偏好、位置搜索、风险查询、提醒订阅、来源说明。
- 非范围：后台管理接口、B2B 接口、批处理运维接口。

## 3. 输入/输出与接口
- 公共请求头：`Authorization: Bearer <access_token>`（匿名接口可无 token）。
- 公共响应字段：`request_id`、`code`、`message`、`retryable`。
- 错误码：`400/401/403/404/409/429/500/503`。

## 4. 数据模型与约束
- 与数据库一致的核心字段：
  - 用户：`user_id`
  - 设备：`device_id`
  - 位置：`location_id`
  - 提醒：`threshold_level`、`enabled`
  - 风险：`risk_overall`、`tree_level`、`grass_level`、`weed_level`、`confidence`

## 5. 异常与降级
- 上游失败：返回缓存结果并附 `is_stale=true`。
- 无权限：返回 401/403，不泄露内部细节。
- 参数非法：返回 400 并给出字段级错误提示。

## 6. 安全与合规
- 客户端只访问 Edge Functions。
- 服务端访问数据库使用 service role。
- 返回数据最小化，不回传内部敏感字段。

## 7. 埋点与可观测性
- 每个请求写入 `request_id` 与耗时。
- 指标：QPS、P95 延迟、错误率、缓存命中率。

## 8. 测试与验收
- 契约测试覆盖所有 endpoint 与错误分支。
- 字段命名校验与 `05` 一致。
- 幂等接口重复调用结果一致。

## 9. 依赖与里程碑
- 依赖：数据库迁移完成、OAuth 可用、缓存策略确定。
- 里程碑：第 5 周接口冻结。

## 10. 假设与默认值
- 默认响应语言由 `lang` 参数或用户 `locale` 决定。
- 默认单位由 `unit_system` 决定。

## Endpoint 列表
1. `POST /v1/auth/exchange`
2. `GET /v1/auth/me`
3. `POST /v1/auth/logout`
4. `PATCH /v1/user/preferences`
5. `GET /v1/locations/suggest?q=&lang=`
6. `GET /v1/pollen/summary?lat=&lng=&lang=&unit=`
7. `GET /v1/pollen/forecast?lat=&lng=&days=&lang=&unit=`
8. `POST /v1/alerts/subscriptions`
9. `GET /v1/meta/sources?lang=`

## 关键响应示例（摘要）
- `summary`:
  - `risk_overall`
  - `tree_level`
  - `grass_level`
  - `weed_level`
  - `confidence`
  - `updated_at`
  - `source`
- `alerts/subscriptions`:
  - `user_id`
  - `location_id`
  - `threshold_level`
  - `enabled`
  - `updated_at`
