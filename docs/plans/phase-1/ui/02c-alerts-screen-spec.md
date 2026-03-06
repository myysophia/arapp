# 02C 提醒页单页规格（Alerts Screen Spec）

## 1. 目标与成功标准
- 目标：让用户用最少操作完成“选择关注城市、设置风险阈值、理解提醒何时触发”。
- 成功标准：用户在 30 秒内可完成提醒开关与阈值配置；权限不足或未登录时也能理解当前状态和下一步动作。

## 2. 范围与非范围
- 范围：关注城市卡、阈值设置、静默时段、提醒记录、通知权限说明、登录同步提示。
- 非范围：多城市提醒、复杂推送规则编排、营销消息设置。

## 3. 输入/输出与接口
- 输入接口：
  - `POST /v1/alerts/subscriptions`
  - `GET /v1/auth/me`
  - `PATCH /v1/user/preferences`
- 输入字段：
  - `user_id`
  - `location_id`
  - `threshold_level`
  - `enabled`
  - `updated_at`
  - `notification_window_start`
  - `notification_window_end`
- 输出：提醒开关状态、阈值数值、保存结果、最近提醒记录。

## 4. 数据模型与约束
- 首版只允许 1 个主关注城市。
- 阈值范围固定 `0-5`，默认值为 `3`。
- 静默时段仅支持 1 段连续区间。
- 最近提醒记录仅展示最近 7 天摘要，不支持详情页。

## 5. 异常与降级
- 未开通知权限：顶部展示权限说明卡，设置区保留但保存后提示需开启系统权限。
- 保存失败：保留用户当前本地修改值，并展示重试提示。
- 未登录：允许本地保存提醒设置，同时展示“登录后可同步”轻提示。
- 无网络：允许查看当前设置快照，但禁用服务端同步状态标签。

## 6. 安全与合规
- 推送文案不得包含医疗诊断或治疗保证。
- 记录展示只显示必要摘要，不显示原始上游 payload。
- 登录提示不得暗示“不登录无法使用提醒”。

## 7. 埋点与可观测性
- `view_alerts`
- `toggle_alert_enabled`
- `change_alert_threshold`
- `save_alert_settings`
- `tap_enable_notifications`
- `tap_login_for_sync`
- 监控：提醒保存成功率、通知权限开启率、提醒页退出前未保存比例。

## 8. 测试与验收
- 阈值从 0 到 5 均可设置并正确回显。
- 未开通知权限时，说明卡、系统设置跳转按钮和保存提示逻辑正确。
- 匿名态与登录态切换后，提醒页状态刷新正确。
- 静默时段跨天边界显示正确。

## 9. 依赖与里程碑
- 依赖：提醒工作流、用户偏好接口、登录状态接口、i18n 文案。
- 里程碑：文档通过后可直接进入提醒页线框与静态页面实现。

## 10. 假设与默认值
- 默认 `enabled=true` 仅在用户主动保存后生效。
- 默认阈值为 `3`。
- 默认静默时段为关闭状态。

## 11. 页面布局
### 11.1 首屏层级
- 页面标题：`提醒`
- 当前关注城市卡：展示城市名、当前提醒状态、更新时间。
- 提醒总开关：紧跟关注城市卡，作为页面首个主交互。
- 阈值设置卡：滑杆 + 当前等级文案。

### 11.2 第二屏层级
- 静默时段卡：起止时间、开关状态。
- 最近 7 天提醒记录卡：列表式摘要。
- 权限或登录说明卡：根据状态条件显示。

## 12. 组件拆分
### 12.1 AlertLocationCard
- props：`locationName`、`isEnabled`、`updatedAt`

### 12.2 AlertToggleRow
- props：`enabled`、`onToggle`

### 12.3 ThresholdSliderCard
- props：`thresholdLevel`、`riskLabelKey`、`onChange`
- 规则：滑杆刻度固定 6 档，不允许连续值。

### 12.4 QuietHoursCard
- props：`enabled`、`startTime`、`endTime`、`onEdit`

### 12.5 AlertHistoryList
- props：`items[]`
- item 字段：`date`、`riskLevel`、`titleKey`

### 12.6 NotificationPermissionCard
- props：`permissionState`、`onOpenSystemSettings`

### 12.7 LoginSyncHintCard
- props：`isAuthenticated`、`onLogin`

## 13. 交互规则
- 调整滑杆时，当前等级文案实时变化。
- 点击“保存”后按钮进入 loading，成功后显示轻提示，不跳页。
- 关闭提醒总开关后，阈值卡和静默时段卡进入弱化态但仍可见。
- 登录成功后仅刷新同步提示和保存状态，不重置滑杆。

## 14. 状态机
- `view_loading -> view_ready`
- `view_ready -> editing`
- `editing -> saving`
- `saving -> save_success`
- `saving -> save_error`
- `view_ready -> notification_permission_denied`
- `view_ready -> anonymous_local_only`

## 15. 文案与视觉规则
- 阈值标题固定使用 `alerts.threshold.title`。
- 当前风险等级标签与首页/地图页颜色映射必须一致。
- “登录后可同步”提示为次级信息卡，不得使用主按钮视觉。
- 记录列表使用时间倒序。

## 16. Figma 搭建建议
- Frame：iPhone 15 Pro 主稿，补小屏高度校验。
- 图层命名：
  - `Alerts/Header`
  - `Alerts/LocationCard`
  - `Alerts/ToggleRow`
  - `Alerts/ThresholdCard`
  - `Alerts/QuietHoursCard`
  - `Alerts/HistoryCard`
  - `Alerts/PermissionCard`
  - `Alerts/LoginSyncCard`
