# 02 UI/UX 规格（专业医疗风，结论优先）

## 1. 目标与成功标准
- 目标：建立可直接进入线框、高保真和开发实现的 UI 规格，确保风险信息清晰、可信、可行动。
- 成功标准：视觉风格、页面结构、组件契约、状态机、交互规则和文案键都可被设计与工程直接执行。
- 当前整理版 Figma 真源：`cf5PnK1WSe5IYRQNGT81fu`
- 历史素材文件：`l629AeywT4tJwH7B3F2EJM`

## 2. 范围与非范围
- 范围：Onboarding、今日、地图、提醒、我的 5 类页面，以及登录入口、空态、错态、离线态、权限态。
- 非范围：付费墙、B2B 看板、复杂个性化报表、深色模式、iPad 专属布局。

## 3. 输入/输出与接口
- 输入：`summary`、`forecast`、`meta/sources`、提醒状态、登录状态、语言与单位偏好。
- 输出：风险等级展示、行动建议、提醒设置反馈、登录绑定状态、来源透明说明。
- 接口依赖：`06-api-edge-functions-contract.md`。
- 文案依赖：`08-i18n-l10n-spec.md`。

## 4. 数据模型与约束
- 导航：底部 4 Tab，顺序固定为“今日 / 地图 / 提醒 / 我的”。
- 风险等级：`0-5`，必须使用“颜色 + 文案 + 图标/标签”双重以上表达，禁止只用颜色。
- 点位标签：首版统一显示 `模型点`，不得暗示为真实监测站。
- 首版仅支持 1 个关注城市；地图浏览可切换城市，但提醒只绑定主城市。
- 登录策略：匿名先用，登录可选，登录入口仅出现在“我的”和需要同步配置的轻提示中。

## 5. 异常与降级
- 无定位权限：展示引导卡与手动选城入口，不阻断进入首页。
- 无网络：优先展示最近缓存，显式显示“最近更新时间”。
- 数据异常：统一使用错误态组件，提供“重试”和“查看来源说明”。
- 推送权限拒绝：提醒页展示说明卡，不隐藏阈值设置能力。
- 登录失败：保持匿名态，不清空当前页面数据。

## 6. 安全与合规
- 页面显式展示“非医疗建议”，至少出现在今日页来源卡和“我的 > 关于与隐私”中。
- 隐私入口固定在“我的 > 隐私与数据”。
- 登录页不得暗示必须登录才能查看基础花粉风险。
- 模型来源、更新时间、数据方法必须可追溯展示。

## 7. 埋点与可观测性
- 页面埋点：`view_today`、`view_map`、`view_alerts`、`view_profile`。
- 行为埋点：`tap_enable_alert`、`tap_login_provider`、`tap_retry_summary`、`tap_select_city`、`switch_locale`。
- UI 质量指标：首屏渲染时长、地图首屏可交互时间、空态命中率、重试点击率。

## 8. 测试与验收
- 双语页面无截断、无硬编码中文。
- 风险色阶映射与文案在所有页面一致。
- 空态、错态、离线态、权限态均有明确视觉反馈。
- 关键页面在 iPhone 标准尺寸下首屏信息完整，不依赖滚动才能理解当前风险。
- 地图详情抽屉、提醒阈值、登录入口三处交互无死路。

## 9. 依赖与里程碑
- 依赖：API 字段冻结、i18n key 清单冻结、提醒算法冻结。
- 里程碑：第 2 周完成高保真与组件清单；第 4 周完成开发标注稿；第 6 周完成 Design QA 首轮。

## 10. 假设与默认值
- 默认主题为浅色。
- 默认单位制 `metric`。
- 默认语言跟随系统（`zh-Hans` 或 `en`）。
- 默认首页为“今日”页。
- 默认首页使用卡片流布局，不使用复杂仪表盘。

## 11. 设计原则
- 结论优先：先告诉用户“现在是否危险”，再展开原因和数据。
- 低认知负担：首屏只保留一个主要结论、一个趋势摘要、一个行动建议区。
- 数据透明：每个风险结论都能追溯到来源、更新时间和类型说明。
- 轻干预：登录、权限、提醒都用非阻断方式引导，不打断主路径。
- 医疗可信感：避免娱乐化图形、夸张动效和过度饱和配色。

## 12. 视觉 Token
### 12.1 色彩
- 品牌主色：`#0E7490`
- 页面背景：`#F7F8F6`
- 卡片背景：`#FFFFFF`
- 主文本：`#0F172A`
- 次文本：`#475569`
- 分割线：`#E5E7EB`
- 成功/低风险：`#22C55E`
- 中风险：`#FACC15`
- 高风险：`#FB923C`
- 很高风险：`#EF4444`
- 极高强调：`#991B1B`

### 12.2 风险色阶映射
| 风险等级 | 文案 key | 背景标签色 | 说明 |
|---|---|---|---|
| 0 | `risk.level.0` | `#CBD5E1` | 几乎无风险 |
| 1 | `risk.level.1` | `#86EFAC` | 非常低 |
| 2 | `risk.level.2` | `#4ADE80` | 低 |
| 3 | `risk.level.3` | `#FACC15` | 中 |
| 4 | `risk.level.4` | `#FB923C` | 高 |
| 5 | `risk.level.5` | `#EF4444` | 很高 |

### 12.3 字体与字号
- 标题 1：28/34，半粗，用于首页风险结论。
- 标题 2：22/28，半粗，用于页面区块标题。
- 标题 3：17/22，中黑，用于卡片标题。
- 正文：15/22，常规。
- 辅助：13/18，常规。
- 数值：使用 tabular figures，用于风险值、时间、阈值。

### 12.4 间距与圆角
- 基础栅格：8pt。
- 页面左右边距：16pt。
- 卡片内边距：16pt。
- 卡片圆角：14pt。
- 主按钮高度：48pt。
- 列表项最小点击区：44x44pt。

## 13. 页面结构
### 13.1 信息架构
- Onboarding：3 屏引导。
- 今日：风险总览、分项、趋势、建议、来源。
- 地图：城市搜索、热力层、点位详情。
- 提醒：阈值、时段、历史记录。
- 我的：登录、语言、单位、隐私、来源与声明。

### 13.2 底部 Tab 规则
- 图标统一线性风格。
- 当前 Tab 使用品牌主色，未选中使用 `#64748B`。
- Tab 标签长度控制在 2-4 个中文字符或 4-8 个英文字符。

### 13.3 Figma 页面映射
- 当前整理版 Figma 文件：`cf5PnK1WSe5IYRQNGT81fu`
- 页面分组：
  - `00 Cover / File Guide`
  - `01 Foundations / System`
  - `02 Mobile Core / Catalog`
  - `03 Main Screens / Home Today`
  - `03 Main Screens / Map Coverage`
  - `03 Main Screens / Alerts Threshold`
  - `03 Main Screens / Profile Account`
  - `03 Main Screens / Auth Login`
  - `03 Main Screens / Onboarding Flow`
  - `04 States & Overlays / Catalog`
- 使用规则：
  - `02 Mobile Core / Catalog` 用于移动端主流程总览与开发对照。
  - `03 Main Screens / ...` 用于单页实现真源。
  - `04 States & Overlays / Catalog` 用于异常态、空态和弹层真源。
  - 旧文件 `l629AeywT4tJwH7B3F2EJM` 仅作为历史素材参考，不再作为实现真源。

## 14. 页面级线框规格
### 14.1 Onboarding
#### 页面目标
- 在不强迫授权的前提下解释产品价值和两类权限的必要性。

#### 页面结构
- 屏 1：主标题、价值说明、插图、`继续`、`跳过`
- 屏 2：定位说明卡、`允许定位`、`手动选城`
- 屏 3：通知说明卡、`允许通知`、`稍后设置`

#### 交互规则
- 任一页都允许跳过。
- 权限拒绝后不重复立即弹系统授权。
- 进入主流程后不再重复展示 Onboarding。

### 14.2 今日页
#### 首屏布局
- 顶部导航区：城市名称、切换入口、更新时间。
- 风险结论卡：风险等级、风险描述、副文案、信心值、主 CTA。
- 分项条：树/草/杂草三项横向条形表示。
- 三日趋势：简化折线或柱线混合图。

#### 次屏布局
- 行动建议卡：2-4 条建议，按风险等级模板化。
- 来源透明卡：来源、更新时间、模型点说明、免责声明。

#### 交互规则
- 下拉刷新只触发一次接口轮询，刷新中禁用重复触发。
- 切换城市后页面整体骨架屏过渡，不闪白。
- 主 CTA 在未开提醒时显示“开启提醒”，已开启时显示“调整阈值”。

### 14.3 地图页
#### 首屏布局
- 顶部浮层：搜索框、当前城市、地图说明入口。
- 主体：风险热力层地图。
- 右下悬浮按钮：定位、图层说明。
- 底部抽屉：默认折叠，选点后展开。

#### 点位抽屉内容
- 点位名称或区域名称。
- 风险等级与更新时间。
- 树/草/杂草三分项。
- 标签：`source.model_point.label`
- CTA：`设为关注城市` / `查看今日详情`

#### 交互规则
- 单击地图点位打开抽屉。
- 再次点击空白区域收起抽屉。
- 地图缩放时不展示复杂标注聚合，首版以热力层为主。

### 14.4 提醒页
#### 页面结构
- 当前关注城市卡。
- 阈值滑杆，范围 0-5。
- 静默时段设置。
- 最近 7 天提醒记录列表。
- 未授权通知说明卡。

#### 交互规则
- 滑杆变更后立即本地反映，点击保存后调用接口。
- 无登录时允许保存到匿名本地；登录后可同步到服务端。
- 通知关闭时，按钮文案改为“前往系统设置”。

### 14.5 我的页
#### 页面结构
- 账户区：头像占位、登录状态、副标题说明。
- 登录按钮组：Google、GitHub、Apple。
- 偏好区：语言、单位、默认城市。
- 隐私与数据：权限状态、隐私政策、删除数据。
- 关于：数据来源、版本号、免责说明。

#### 交互规则
- 未登录时不展示空白资料卡，显示价值说明与登录按钮。
- 登录成功后停留当前页，仅局部更新状态。
- 删除数据为危险操作，二次确认。

## 15. 组件契约
### 15.1 RiskHeroCard
- props：`riskLevel`、`riskLabelKey`、`updatedAt`、`confidence`、`cityName`、`primaryAction`
- 状态：`default/loading/stale/error`
- 规则：必须展示更新时间；`confidence < 0.5` 时增加低信心提示。

### 15.2 PollenBreakdownBar
- props：`treeLevel`、`grassLevel`、`weedLevel`
- 规则：三项顺序固定，不允许根据值重排。

### 15.3 TrendMiniChart
- props：`points[3]`、`locale`、`unitSystem`
- 规则：首版固定展示 3 天，不提供横向滚动。

### 15.4 ActionAdviceCard
- props：`riskLevel`、`adviceKeys[]`
- 规则：建议内容由文案 key 驱动，不在组件内写死文本。

### 15.5 SourceTransparencyCard
- props：`providerName`、`sourceType`、`updatedAt`、`licenseNoteKey`
- 规则：`sourceType=model` 时必须显示模型点说明。

### 15.6 AuthProviderButton
- props：`provider`、`state`、`onTap`
- provider：`google/github/apple`
- 状态：`default/loading/error/disabled`

### 15.7 StateView
- props：`stateType`、`titleKey`、`bodyKey`、`ctaKey`
- 类型：`empty/error/offline/no_permission/no_notification`

### 15.8 Figma 组件命名规则
- Figma 中的组件命名以全局组件名为准，不再沿用旧的页面前缀式历史命名。
- 全局组件真源：
  - `RiskHeroCard`
  - `PollenBreakdownBar`
  - `TrendMiniChart`
  - `ActionAdviceCard`
  - `SourceTransparencyCard`
  - `AuthProviderButton`
  - `StateView`
- 页面内局部结构允许使用 `Home / Today / Header`、`Map / Coverage / Bottom Sheet` 这类页面级 frame 名称，但共享组件必须回到全局组件名。

## 16. 状态机
### 16.1 首页状态
- `loading -> success`
- `loading -> stale_success`
- `loading -> error`
- `success -> refresh_loading -> success`

### 16.2 登录状态
- `anonymous`
- `auth_in_progress`
- `authenticated`
- `auth_failed`

### 16.3 提醒状态
- `disabled`
- `enabled`
- `system_permission_denied`
- `sync_pending`

## 17. 动效与反馈
- 首屏风险卡入场：淡入 + 上移 220ms。
- 风险等级变化：背景色与标签色 180ms 过渡。
- 地图抽屉展开：弹簧动画 240ms。
- 登录按钮点击：进入 loading 态，最长 10s 后必须回到可点击状态。
- 禁止使用大面积视差、粒子、玻璃拟态。

## 18. 可访问性
- 对比度至少满足 WCAG AA。
- 动态字体支持 iOS 辅助字号。
- 关键 CTA 和列表项点击面积 >= 44x44pt。
- 风险结论必须能被 VoiceOver 完整朗读，顺序为“城市、风险等级、更新时间、建议入口”。

## 19. 文案键与追溯
| 文案 key | 使用位置 | 关联测试 |
|---|---|---|
| `risk.level.0`-`risk.level.5` | 今日页、地图抽屉 | I18N-001 |
| `disclaimer.non_medical` | 今日页来源卡、我的页关于 | I18N-002 |
| `source.model_point.label` | 地图抽屉、来源透明卡 | I18N-003 |
| `auth.provider.google` | 我的页登录按钮 | I18N-004 |
| `alerts.threshold.title` | 提醒页阈值区 | I18N-005 |
| `state.offline.title` | 全局离线态 | UI-STATE-001 |
| `state.no_permission.location` | 首页/地图权限态 | UI-STATE-002 |

## 20. Design QA 清单
- 风险色、标签、文案是否全页面一致。
- 今日页首屏是否无需滚动即可理解当前结论。
- 地图点位是否明确为模型点。
- 登录入口是否非阻断。
- 双语按钮、导航、卡片标题是否有截断。
- 空态、错态、离线态、权限态是否都有对应视觉稿。

## 21. 子文档索引
- 首页单页规格：`ui/02a-home-screen-spec.md`
- 地图页单页规格：`ui/02b-map-screen-spec.md`
- 提醒页单页规格：`ui/02c-alerts-screen-spec.md`
- 我的页单页规格：`ui/02d-profile-screen-spec.md`
- 后续建议补充：Onboarding 分页规格。
