# Figma 整编文件设计方案

## 背景
- 当前 Figma 真源文件 `l629AeywT4tJwH7B3F2EJM` 是通过 HTML capture 逐步追加形成的展示稿。
- 现有文件存在历史包袱：顶层仍为 `Page 1`，页面命名不统一，且混有浏览器扩展残留节点与桌面展示稿。
- T01 的目标不是改视觉，而是把 Figma 从“展示稿”整理成“开发稿”，让后续 Agent 能稳定按页面、组件、状态并行协作。

## 目标
- 新建一个整理版 Figma 文件，作为 Phase 1 设计真源。
- 用统一页面分组承接现有设计资产，避免继续在旧文件上叠历史结构。
- 让文件结构与本地文档、TODO、Linear issue 的命名保持一致。

## 约束
- 当前 Figma MCP 能稳定读取与生成文件，但不适合对旧文件做大规模重命名和重排。
- 当前阶段只做设计治理，不改业务功能和 UI 文案内容。
- 旧文件需要保留，作为历史设计素材与比对来源。

## 方案对比

### 方案 A：直接在旧文件上重命名和重排
- 优点：延续现有链接，不需要迁移。
- 缺点：MCP 对结构化编辑支持不足，容易留下半整理状态；旧的 capture 残留层无法可靠清理。
- 结论：不采用。

### 方案 B：新建整理版文件，并在新文件中重建目录、基础页和主页面入口
- 优点：结构干净，命名可以一次定准；后续所有页面扩展都能沿用统一信息架构。
- 缺点：旧文件链接需要降级为“历史参考”，后续文档要回写新真源。
- 结论：推荐并采用。

### 方案 C：只在旧文件中追加封面页和目录页，不迁移真源
- 优点：成本最低。
- 缺点：治标不治本，主文件仍然混乱；多 Agent 协作时仍会误入旧 frame。
- 结论：不采用。

## 采用方案
- 采用方案 B：新建整理版 Figma 文件，旧文件降级为历史素材源。
- 新文件 fileKey：`cf5PnK1WSe5IYRQNGT81fu`
- 旧文件 fileKey：`l629AeywT4tJwH7B3F2EJM`

## 新文件结构
新文件按页面分组组织：
1. `00 Cover`
2. `01 Foundations`
3. `02 Mobile Core`
4. `03 Main Screens`
5. `04 States & Overlays`

### 页面内容
- `00 Cover`
  - 文件说明
  - 使用规则
  - 历史来源链接说明
- `01 Foundations`
  - Logo
  - 品牌色 / 中性色
  - 风险色阶 0-5
  - 字体层级
  - 间距 / 圆角 / 按钮
- `02 Mobile Core`
  - Today
  - Map
  - Alerts
  - Profile
  - Login
  - Onboarding
- `03 Main Screens`
  - 首页展示稿
  - 地图页展示稿
  - 提醒页展示稿
  - 我的页展示稿
  - 登录页展示稿
- `04 States & Overlays`
  - No Location
  - Offline Cache
  - Empty Alerts
  - Search Sheet
  - Source Sheet
  - Danger Dialog

## 命名规范

### 页面命名
- `Home / Today`
- `Map / Coverage`
- `Alerts / Threshold`
- `Profile / Account`
- `Auth / Login`
- `Onboarding / Step 1`
- `Onboarding / Step 2`
- `Onboarding / Step 3`

### 组件命名
- `RiskHeroCard`
- `PollenBreakdownBar`
- `TrendMiniChart`
- `ActionAdviceCard`
- `SourceTransparencyCard`
- `AuthProviderButton`
- `StateView`

## 治理规则
- 旧文件 `l629AeywT4tJwH7B3F2EJM` 标记为“历史素材，不再作为真源”。
- 新文件作为 `TODO.md`、UI 文档、Linear `NIN-5 / T01` 的设计真源。
- 后续页面修改优先在新文件完成，再决定是否需要把旧内容补迁移。

## 交付物
1. 新的整理版 Figma 文件链接
2. 新文件中的封面页和基础页
3. 新文件中的页面命名与分组规范
4. 本地文档回写：
   - `TODO.md`
   - `docs/plans/phase-1/02-ui-ux-spec.md`

## 验收标准
- 存在新的整理版 Figma 文件。
- 新文件首屏可见 `00 Cover / 01 Foundations / 02 Mobile Core / 03 Main Screens / 04 States & Overlays` 五组内容。
- 页面命名与 `02-ui-ux-spec.md`、`ui/02a-02d` 文档一致。
- `TODO.md` 中的设计真源已切换到新文件。

## 风险与缓解
- 风险：MCP 不能直接复制旧文件中的所有 frame。
  - 缓解：优先新建目录页和基础页；旧页面通过本地原型重新 capture 到新文件。
- 风险：文档与 Figma 链接不同步。
  - 缓解：本次执行结束前统一回写真源链接。
