# TODO List

## [Phase 1 - 多 Agent 并行开发] (优先级: 高)
创建时间：2026-03-06 17:40
更新时间：2026-03-06 17:40 - 初始化多 Agent 并行任务清单

### 并行开发规则
- 每个任务必须有单一产出物，避免多个 Agent 同时改同一文件。
- 每个任务优先控制在半天到一天内完成，可独立提交一个 PR。
- 共享真源固定为：
  - 设计真源：`Figma 文件 l629AeywT4tJwH7B3F2EJM`
  - UI 规格真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`
  - 数据库真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/05-db-schema-supabase.sql.md`
  - API 真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/06-api-edge-functions-contract.md`
- 并行时优先按目录隔离：
  - 设计与文档：`docs/plans/phase-1/`
  - 原型与设计导出：`prototype/homepage/`
  - 未来 iOS 工程建议拆分为：`App`、`Features`、`SharedUI`、`Models`、`Services`、`Tests`
- 每个任务完成后都要回填：完成说明、变更文件、阻塞项。

### 建议 Agent 编组
- Agent A：设计系统与 Figma 整理
- Agent B：iOS 工程骨架与导航
- Agent C：共享组件与设计 Token
- Agent D：数据模型、Mock、API 适配层
- Agent E：页面实现（Today / Map / Alerts / Profile）
- Agent F：测试、国际化、验收

### Wave 0：立即可并行启动
- [ ] T01 - 整理 Figma 页面结构与命名
  - 建议负责人：Agent A
  - 预计时长：0.5 天
  - 依赖：无
  - 输出物：统一页面分组、画板命名、封面说明、组件页入口
  - 主要边界：只动 Figma，不改代码
  - 成功标准：Figma 内形成 `00 Cover / 01 Foundations / 02 Mobile Core / 03 Main Screens / 04 States & Overlays`

- [ ] T02 - 回写 UI 文档与 Figma 命名映射
  - 建议负责人：Agent A
  - 预计时长：0.5 天
  - 依赖：T01
  - 输出物：更新 `02-ui-ux-spec.md` 和 `ui/02a-02d` 文档中的页面命名与组件命名
  - 主要文件：`/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`、`/Users/ninesun/projects/arapp/docs/plans/phase-1/ui/`
  - 成功标准：文档中的页面名、组件名与 Figma 完全一致

- [ ] T03 - 初始化 iOS 工程骨架与目录约定
  - 建议负责人：Agent B
  - 预计时长：1 天
  - 依赖：无
  - 输出物：SwiftUI App 入口、TabView 骨架、目录结构、构建通过
  - 主要边界：只建工程与空页面，不接真实数据
  - 成功标准：项目可在模拟器启动，四个 Tab 和登录入口可见

- [ ] T04 - 定义设计 Token 到 SwiftUI 的映射
  - 建议负责人：Agent C
  - 预计时长：0.5 天
  - 依赖：无
  - 输出物：颜色、字号、圆角、间距、阴影等 Token
  - 主要边界：仅创建 `SharedUI` 中的主题文件，不实现业务页面
  - 成功标准：颜色和排版与 `system.html`、Figma Foundations 页一致

- [ ] T05 - 建立领域模型与 Mock 数据
  - 建议负责人：Agent D
  - 预计时长：1 天
  - 依赖：无
  - 输出物：`PollenSummary`、`PollenForecast`、`AlertSubscription`、`SourceMeta` 等模型与 Mock JSON/Swift Fixtures
  - 主要边界：只动 `Models`、`Mocks`，不改页面
  - 成功标准：模型字段与 `05`、`06` 文档一致，Mock 可驱动页面预览

- [ ] T06 - 建立测试骨架与基线校验
  - 建议负责人：Agent F
  - 预计时长：0.5 天
  - 依赖：T03
  - 输出物：单元测试 target、UI 测试 target、基础快照或冒烟测试
  - 主要边界：只建测试基础设施，不写复杂用例
  - 成功标准：测试 target 可运行，有至少 1 个通过的冒烟测试

### Wave 1：页面静态实现，可并行
- [ ] T07 - 实现 Today 页面静态骨架
  - 建议负责人：Agent E1
  - 预计时长：1 天
  - 依赖：T03、T04、T05
  - 输出物：Today 页面静态布局
  - 主要边界：只动 `Features/Today`
  - 成功标准：匹配 `mobile-core` 中 Today 屏的层级和组件结构

- [ ] T08 - 实现 Map 页面静态骨架
  - 建议负责人：Agent E2
  - 预计时长：1 天
  - 依赖：T03、T04、T05
  - 输出物：Map 页面静态布局、底部抽屉占位
  - 主要边界：只动 `Features/Map`
  - 成功标准：匹配 `mobile-core` 中 Map 屏和 `states-overlays` 中 search/source sheet

- [ ] T09 - 实现 Alerts 页面静态骨架
  - 建议负责人：Agent E3
  - 预计时长：1 天
  - 依赖：T03、T04、T05
  - 输出物：Alerts 页面静态布局、阈值选择控件占位
  - 主要边界：只动 `Features/Alerts`
  - 成功标准：匹配 `mobile-core` 中 Alerts 屏和空提醒状态

- [ ] T10 - 实现 Profile 页面静态骨架
  - 建议负责人：Agent E4
  - 预计时长：1 天
  - 依赖：T03、T04、T05
  - 输出物：Profile 页面静态布局、登录状态双态占位
  - 主要边界：只动 `Features/Profile`
  - 成功标准：匹配 `mobile-core` 中 Profile 屏，支持已登录/未登录双态预览

- [ ] T11 - 实现 Auth / Login 页面静态骨架
  - 建议负责人：Agent B
  - 预计时长：0.5 天
  - 依赖：T03、T04
  - 输出物：Login 页面、匿名继续入口、三方按钮样式
  - 主要边界：只动 `Features/Auth`
  - 成功标准：不接真实 Supabase，仅支持 UI 预览与路由进入

- [ ] T12 - 实现 Onboarding 静态骨架
  - 建议负责人：Agent B
  - 预计时长：0.5 天
  - 依赖：T03、T04
  - 输出物：三屏 Onboarding、分页点、权限引导文案
  - 主要边界：只动 `Features/Onboarding`
  - 成功标准：支持预览三屏和跳过主流程

### Wave 2：共享组件与状态页，可并行
- [ ] T13 - 提取共享组件第一批
  - 建议负责人：Agent C
  - 预计时长：1 天
  - 依赖：T07、T08、T09、T10 至少完成两个
  - 输出物：`RiskHeroCard`、`TrendMiniChart`、`AuthProviderButton`
  - 主要边界：只动 `SharedUI/Components`
  - 成功标准：页面中重复结构被抽离，接口命名与文档一致

- [ ] T14 - 提取共享组件第二批
  - 建议负责人：Agent C
  - 预计时长：1 天
  - 依赖：T13
  - 输出物：`PollenBreakdownBar`、`SourceTransparencyCard`、`StateView`
  - 主要边界：只动 `SharedUI/Components`
  - 成功标准：所有主页面不再内嵌重复 UI 结构

- [ ] T15 - 实现状态页与弹层
  - 建议负责人：Agent E5
  - 预计时长：1 天
  - 依赖：T08、T09、T10、T14
  - 输出物：No Location、Offline Cache、Empty Alerts、Search Sheet、Source Sheet、Danger Dialog
  - 主要边界：只动 `SharedUI/States` 或各 Feature 的 `Overlays`
  - 成功标准：与 `states-overlays.html` 对齐，可由预览或 demo 触发

### Wave 3：数据接线与真实流程，可并行
- [ ] T16 - 建立 Supabase Auth 接口适配层
  - 建议负责人：Agent D
  - 预计时长：1 天
  - 依赖：T11
  - 输出物：登录 provider 枚举、会话接口、假实现和真实现边界
  - 主要边界：只动 `Services/Auth`
  - 成功标准：UI 层不直接依赖 Supabase SDK 细节

- [ ] T17 - 建立 Pollen API Client 与错误模型
  - 建议负责人：Agent D
  - 预计时长：1 天
  - 依赖：T05
  - 输出物：summary、forecast、meta sources、alerts subscriptions 的 client 层
  - 主要边界：只动 `Services/API`
  - 成功标准：接口字段与 `06-api-edge-functions-contract.md` 一致

- [ ] T18 - Today 页面接入 Mock -> Client 双模式
  - 建议负责人：Agent E1
  - 预计时长：0.5 天
  - 依赖：T07、T17
  - 输出物：Today 页可切换 Mock 和 Client
  - 成功标准：空态、加载态、成功态、失败态完整

- [ ] T19 - Map 页面接入 Mock -> Client 双模式
  - 建议负责人：Agent E2
  - 预计时长：0.5 天
  - 依赖：T08、T17、T15
  - 输出物：Map 页数据和抽屉内容可切换
  - 成功标准：支持来源说明抽屉和模型点标签

- [ ] T20 - Alerts 页面接入 Mock -> Client 双模式
  - 建议负责人：Agent E3
  - 预计时长：0.5 天
  - 依赖：T09、T17
  - 输出物：阈值、静默时段、历史记录可从 mock 和 client 读取
  - 成功标准：空态与已配置态可切换

- [ ] T21 - Profile/Auth 页面接入 Auth 假流程
  - 建议负责人：Agent E4
  - 预计时长：0.5 天
  - 依赖：T10、T11、T16
  - 输出物：未登录、登录中、已登录三态
  - 成功标准：按钮动作打到假接口，状态切换可演示

### Wave 4：国际化、测试、验收
- [ ] T22 - 接入双语文案与格式化
  - 建议负责人：Agent F
  - 预计时长：1 天
  - 依赖：T07-T12 至少完成四项
  - 输出物：`zh-Hans`、`en` 的字符串表和格式化适配
  - 主要边界：只动 `Resources/Localization`、格式化工具
  - 成功标准：关键页面可切换中英文，不出现硬编码中文

- [ ] T23 - 补齐单元测试与 UI 冒烟测试
  - 建议负责人：Agent F
  - 预计时长：1 天
  - 依赖：T18-T21
  - 输出物：页面状态测试、模型映射测试、基本导航测试
  - 主要边界：只动 `Tests`
  - 成功标准：至少覆盖 Today、Map、Alerts 的核心状态切换

- [ ] T24 - 开发收口与文档回填
  - 建议负责人：Agent A + Agent F
  - 预计时长：0.5 天
  - 依赖：T22、T23
  - 输出物：更新 UI 文档、测试计划、交付记录
  - 主要文件：`docs/plans/phase-1/02-ui-ux-spec.md`、`10-testing-acceptance-plan.md`
  - 成功标准：设计、实现、测试三份真源一致

## 当前推荐启动顺序
- 第一天并行启动：T01、T03、T04、T05
- 第二天并行启动：T06、T07、T08、T09、T10、T11、T12
- 第三天开始：T13、T14、T15、T16、T17
- 第四天开始：T18、T19、T20、T21、T22
- 最后收口：T23、T24

## 已完成任务
- 暂无
