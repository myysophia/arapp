# 05 Supabase 数据库结构规范（唯一真源）

## 1. 目标与成功标准
- 目标：定义可直接迁移的 Supabase 表结构、索引、RLS、触发器。
- 成功标准：表结构可执行，权限边界清晰，字段命名与 API 完整一致。

## 2. 范围与非范围
- 范围：`public` 业务表 + `auth.users` 关联 + PostGIS + RLS。
- 非范围：分析数仓、BI 宽表、历史归档系统。

## 3. 输入/输出与接口
- 输入：认证用户、设备、位置、风险数据、提醒事件。
- 输出：稳定持久化数据，供 Edge Functions 查询与写入。
- 对外映射：`06-api-edge-functions-contract.md`。

## 4. 数据模型与约束
- 关键表：
  - `profiles(user_id, display_name, avatar_url, created_at, updated_at)`
  - `user_preferences(user_id, locale, unit_system, tz, notification_window_start, notification_window_end, updated_at)`
  - `devices(id, user_id, device_id, platform, apns_token, is_active, last_seen_at, created_at, updated_at)`
  - `locations(id, name, country_code, admin1, lat, lng, geog, is_active, created_at, updated_at)`
  - `user_saved_locations(id, user_id, location_id, alias_name, is_primary, created_at)`
  - `alert_subscriptions(id, user_id, location_id, threshold_level, enabled, quiet_hours, created_at, updated_at)`
  - `pollen_daily_cache(id, cell_key, target_date, source, risk_overall, tree_level, grass_level, weed_level, confidence, payload_jsonb, fetched_at, expires_at)`
  - `pollen_tile_cache(id, source, target_date, z, x, y, tile_url, etag, expires_at)`
  - `data_sources(id, source, provider_name, coverage_note, license_note, active, created_at, updated_at)`
  - `notification_events(id, user_id, device_id, location_id, event_type, payload_jsonb, status, sent_at, created_at)`
  - `audit_events(id, actor_user_id, action, resource_type, resource_id, meta_jsonb, created_at)`
- 约束：
  - `threshold_level` 与各 risk 字段范围 `0-5`
  - `confidence` 范围 `0-1`
  - `unique(user_id, location_id)` 约束于 `user_saved_locations`、`alert_subscriptions`
  - 缓存唯一键：`unique(cell_key, target_date, source)`

## 5. 异常与降级
- 写入冲突：使用 upsert 或幂等键。
- 上游数据缺失：允许缓存表部分分项为空，不允许 `risk_overall` 为空。

## 6. 安全与合规
- 开启 RLS：`profiles/user_preferences/devices/user_saved_locations/alert_subscriptions`。
- 策略：仅 `auth.uid()=user_id` 可访问本人数据。
- 服务端专用表：`pollen_*`、`data_sources`、`notification_events`、`audit_events` 仅 service role。

## 7. 埋点与可观测性
- 表级审计：`audit_events`。
- 推送链路审计：`notification_events`。

## 8. 测试与验收
- RLS 越权测试必须全部失败。
- 关键唯一约束与 check 约束测试通过。
- PostGIS 索引生效（附近查询走 GIST）。

## 9. 依赖与里程碑
- 依赖：Supabase 项目创建、扩展权限、迁移工具。
- 里程碑：第 4 周前完成迁移并通过本地/预发验证。

## 10. 假设与默认值
- 主键统一 UUID。
- 时间字段统一 timestamptz。
- 默认时区记录为 `Asia/Shanghai`。

## 迁移顺序
1. 扩展与枚举类型（pgcrypto、postgis、enum）。
2. 基础表与外键。
3. 索引与唯一约束。
4. `updated_at` 触发器与 `handle_new_user` 触发器。
5. RLS 与策略。
