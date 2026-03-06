# 02A 首页单页规格（Home Screen Spec）

## 1. 目标与成功标准
- 目标：让用户在进入应用后的 3 秒内明确知道“当前城市的花粉风险等级”和“下一步该做什么”。
- 成功标准：首屏无需滚动即可理解结论；主要 CTA 清晰；风险、趋势、建议、来源四块信息可完整闭环。

## 2. 范围与非范围
- 范围：首页视觉层级、组件布局、状态切换、骨架屏、空态与异常态。
- 非范围：地图交互、支付入口、历史报告详情页。

## 3. 输入/输出与接口
- 输入接口：`GET /v1/pollen/summary`、`GET /v1/pollen/forecast`、`GET /v1/meta/sources`
- 输入字段：
  - `city_name`
  - `risk_overall`
  - `tree_level`
  - `grass_level`
  - `weed_level`
  - `confidence`
  - `updated_at`
  - `source`
- 输出：首页 UI 渲染、主 CTA 状态、刷新与重试行为。

## 4. 数据模型与约束
- 首屏必须包含 4 个主模块：
  - 顶部城市与更新时间
  - 风险结论卡
  - 三日趋势卡
  - 行动建议卡
- 来源透明卡位于第二屏顶部，不能挤入首屏核心结论区。
- 三日趋势固定 3 天，不支持横向滚动。
- 主 CTA 唯一，避免首页同时出现多个主操作按钮。

## 5. 异常与降级
- `loading`：显示骨架屏，不显示旧错误文案。
- `stale_success`：显示缓存数据并标注“更新较早”。
- `error`：展示错误态卡片，提供 `重试`。
- `no_location_permission`：顶部显示权限提示卡，默认回退到手动选城结果。
- `offline`：保留最后一次成功数据，禁用下拉刷新动画。

## 6. 安全与合规
- 页面底部来源卡必须包含 `disclaimer.non_medical`。
- 风险文案不得使用“诊断”“处方”“治疗有效”等医疗承诺表达。
- `source=model` 时必须显示“模型点/模型预测”标签。

## 7. 埋点与可观测性
- `view_today`
- `pull_to_refresh_today`
- `tap_primary_cta_today`
- `tap_retry_summary`
- `tap_source_transparency`
- 监控：首屏渲染时长、summary 接口耗时、forecast 接口耗时。

## 8. 测试与验收
- 首页首屏在常见 iPhone 尺寸下不依赖滚动即可看到风险等级、趋势摘要、主 CTA。
- `risk_overall`、`tree_level`、`grass_level`、`weed_level` 与颜色映射一致。
- `confidence < 0.5` 时出现低信心辅助提示。
- 离线态、异常态、权限态均有单独视觉稿和测试用例。

## 9. 依赖与里程碑
- 依赖：总 UI 文档、API 契约、i18n key、提醒页 CTA 跳转定义。
- 里程碑：该文档通过后，可直接进入首页线框、Figma 高保真和静态前端实现。
- 对应 Figma 页面：`03 Main Screens / Home Today`
- 关联目录页：`02 Mobile Core / Catalog`
- 关联状态页：`04 States & Overlays / Catalog`

## 10. 假设与默认值
- 默认城市优先使用用户上次选择的城市。
- 未开启提醒时，主 CTA 为“开启提醒”。
- 已开启提醒时，主 CTA 为“调整阈值”。

## 11. 版面结构
### 11.1 首屏层级
- 顶部导航：城市名称、切换入口、更新时间。
- 风险结论卡：页面视觉重心，占据首屏约 40% 高度。
- 分项概览：树/草/杂草三条横条，紧跟风险卡。
- 三日趋势：一张紧凑图卡，放在首屏底部。

### 11.2 第二屏层级
- 行动建议卡：2-4 条建议，按优先级排序。
- 来源透明卡：来源、方法、更新时间、免责声明。
- 次级入口：查看地图、查看更多来源说明。

## 12. 组件拆分
### 12.1 顶部导航区
- 左侧：城市名。
- 右侧：切换城市入口。
- 副文案：`updated_at` 的相对时间或绝对时间。

### 12.2 风险结论卡
- 标题：风险等级文案。
- 副标题：一句总结性文案，如“今天不建议长时间暴露在户外花粉环境中”。
- 辅助信息：`confidence`、更新时间。
- 主 CTA：单按钮。

### 12.3 分项概览卡
- 每项包含：名称、等级标签、进度条。
- 顺序固定：树、草、杂草。

### 12.4 三日趋势卡
- 标题：`未来 3 天趋势`
- 图表：3 个点位，横轴为日期标签，纵轴为风险等级。
- 说明：若后两天风险升高，用一行强调文本提示。

### 12.5 行动建议卡
- 内容来自 `adviceKeys[]`。
- 每条建议由短标题 + 一行说明组成。
- 高风险等级时第一条建议必须与外出/防护相关。

### 12.6 来源透明卡
- 来源名
- 来源类型标签
- 更新时间
- 免责说明
- 次级动作：`查看数据说明`

## 13. 文案与视觉规则
- 风险结论卡标题最多 6 个中文字符或 14 个英文字符。
- 三日趋势标题固定使用 key，不允许设计稿里手写文本。
- 主 CTA 颜色固定为品牌主色实心按钮。
- 来源透明卡视觉弱于风险结论卡，不与首屏主结论竞争。

## 14. 状态图
- `init -> loading -> success`
- `loading -> stale_success`
- `loading -> error`
- `success -> refreshing -> success`
- `success -> refreshing -> stale_success`

## 15. Figma 搭建建议
- Frame：iPhone 15 Pro 尺寸为主，补 iPhone SE 高度校验。
- 使用 Auto Layout 组织页面，不使用绝对定位堆卡片。
- 页面级 frame 命名：
  - `Home / Today / Header`
  - `Home / Today / Content`
  - `Home / Today / Secondary Section`
- 共享组件命名：
  - `RiskHeroCard`
  - `PollenBreakdownBar`
  - `TrendMiniChart`
  - `ActionAdviceCard`
  - `SourceTransparencyCard`
