# 02B 地图页单页规格（Map Screen Spec）

## 1. 目标与成功标准
- 目标：让用户通过地图快速理解不同区域的花粉风险分布，并能把某个区域设置为关注城市。
- 成功标准：搜索、浏览、选点、展开详情、设为关注城市这一条链路可以在单页内顺畅完成。

## 2. 范围与非范围
- 范围：地图页布局、热力层、点位抽屉、说明入口、定位按钮、空态与异常态。
- 非范围：路线规划、多图层叠加、真实监测站聚合展示。

## 3. 输入/输出与接口
- 输入接口：
  - `GET /v1/locations/suggest`
  - `GET /v1/pollen/summary`
  - `GET /v1/meta/sources`
- 输入字段：
  - `location_id`
  - `risk_overall`
  - `tree_level`
  - `grass_level`
  - `weed_level`
  - `updated_at`
  - `source`
- 输出：地图热力层状态、点位抽屉内容、设为关注城市动作。

## 4. 数据模型与约束
- 首版仅支持热力层 + 详情抽屉，不做复杂聚合图例切换。
- 抽屉内 CTA 至多 2 个：`设为关注城市`、`查看今日详情`。
- 所有点位必须以 `模型点` 进行语义标识。
- 默认地图中心优先为当前城市，其次为上次浏览位置。

## 5. 异常与降级
- 无定位权限：地图仍可浏览，定位按钮触发权限说明而不是空操作。
- 地图数据加载失败：保留底图，热力层显示失败说明卡。
- 网络差：优先展示最近可用热力层元信息，并禁用刷新动作。
- 未取到点位详情：抽屉显示“暂无详情，稍后重试”。

## 6. 安全与合规
- 地图说明入口必须明确说明“当前为模型推断结果”。
- 不得在地图页使用“监测站”字样描述模型点。
- 抽屉中的来源说明必须和首页来源透明逻辑一致。

## 7. 埋点与可观测性
- `view_map`
- `search_city_on_map`
- `tap_map_point`
- `expand_map_bottom_sheet`
- `set_primary_city_from_map`
- 监控：地图首屏可交互时间、点位详情接口耗时、抽屉打开率。

## 8. 测试与验收
- 搜索城市后地图中心、点位抽屉内容与顶部城市标签一致。
- 点位抽屉能正确展示 `risk_overall/tree_level/grass_level/weed_level`。
- 模型点标签始终可见。
- 无定位权限与弱网下页面仍可使用核心浏览能力。

## 9. 依赖与里程碑
- 依赖：地图 SDK、位置搜索接口、来源透明文案、首页“查看今日详情”跳转定义。
- 里程碑：地图页文档通过后，可直接进入交互稿与 Figma 结构稿。

## 10. 假设与默认值
- 首版使用 MapKit 标准底图。
- 不做用户绘制路线、收藏多个点位、图层选择器。
- 首版抽屉默认半高态，不支持多级停靠。

## 11. 页面布局
### 11.1 顶部浮层
- 搜索框：全宽，支持城市名称搜索。
- 城市标签：展示当前城市，位于搜索框下方或内嵌右侧。
- 说明入口：小型信息图标，点击打开底部说明弹层。

### 11.2 地图主体
- 默认显示热力层。
- 右下角按钮区：
  - 定位按钮
  - 图层说明按钮
- 不显示复杂 legend 面板，首版仅用小型渐变条或说明弹层表达色阶。

### 11.3 底部抽屉
- 抽屉头部：区域名 + 风险标签。
- 内容区：
  - 更新时间
  - 三分项等级
  - 模型点标签
  - 简短建议
- CTA 区：
  - 主按钮：设为关注城市
  - 次按钮：查看今日详情

## 12. 交互规则
- 点击地图高风险区域，优先打开该区域对应抽屉。
- 点击空白区域，收起抽屉但保留地图位置。
- 点击搜索结果后，地图平滑移动到城市中心并刷新热力层。
- 若当前选中城市已经是关注城市，主按钮改为“已是关注城市”禁用态。

## 13. 组件拆分
### 13.1 MapSearchBar
- props：`query`、`selectedCityName`、`onSearch`、`onSelectCity`

### 13.2 MapHeatLayer
- props：`cityCenter`、`riskLegend`、`state`
- state：`loading/ready/error/stale`

### 13.3 MapFloatingActions
- props：`onLocate`、`onOpenLegend`

### 13.4 MapPointBottomSheet
- props：
  - `locationId`
  - `locationName`
  - `riskOverall`
  - `treeLevel`
  - `grassLevel`
  - `weedLevel`
  - `updatedAt`
  - `source`
  - `primaryAction`
  - `secondaryAction`

## 14. 状态机
- `idle -> map_loading -> map_ready`
- `map_ready -> point_loading -> point_ready`
- `point_loading -> point_error`
- `map_loading -> map_error`
- `map_ready -> searching_city -> map_loading`

## 15. 文案与视觉规则
- 抽屉标题最多 10 个中文字符或 24 个英文字符。
- 风险标签始终放在标题可视区，不折叠到次级信息里。
- 模型点标签使用次级胶囊，不用主色按钮样式。
- 搜索框与地图按钮必须保持足够对比度，避免被热力层吞没。

## 16. Figma 搭建建议
- Frame：iPhone 15 Pro 主设计稿，补 1 个小屏校验 frame。
- 图层命名：
  - `Map/TopSearch`
  - `Map/HeatLayer`
  - `Map/FloatingActions`
  - `Map/BottomSheet`
  - `Map/LegendSheet`
- 底部抽屉用 component variants 表达：`collapsed / half / error`。
