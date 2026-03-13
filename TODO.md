# TODO List

## [Phase 1 - 多 Agent 并行开发] (优先级: 高)
创建时间：2026-03-06 17:40
更新时间：2026-03-06 19:35 - 回写 Linear 项目、Agent lane、优先级与 assignee 规则

### 并行开发规则
- 每个任务必须有单一产出物，避免多个 Agent 同时改同一文件。
- 每个任务优先控制在半天到一天内完成，可独立提交一个 PR。
- 共享真源固定为：
  - 设计真源：`Figma 文件 cf5PnK1WSe5IYRQNGT81fu`
  - 历史素材源：`Figma 文件 l629AeywT4tJwH7B3F2EJM`
  - UI 规格真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`
  - 数据库真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/05-db-schema-supabase.sql.md`
  - API 真源：`/Users/ninesun/projects/arapp/docs/plans/phase-1/06-api-edge-functions-contract.md`
- 并行时优先按目录隔离：
  - 设计与文档：`docs/plans/phase-1/`
  - 原型与设计导出：`prototype/homepage/`
  - 未来 iOS 工程建议拆分为：`App`、`Features`、`SharedUI`、`Models`、`Services`、`Tests`
- 每个任务完成后都要回填：完成说明、变更文件、阻塞项。

### Linear 真源
- Linear 项目：`arapp Phase 1`
- Linear 链接：`https://linear.app/ninesun/project/arapp-phase-1-00573ec1698e`
- Wave 里程碑：
  - `Wave 0 Foundations`
  - `Wave 1 Static Screens`
  - `Wave 2 Shared Components`
  - `Wave 3 Integration`
  - `Wave 4 QA Release`
- 本地 `TODO.md` 用于说明执行规则；任务状态、依赖、优先级、指派以 Linear 为准。

### Linear 指派与标签规则
- `assignee`：所有任务统一指派给真实 owner `王九日`，避免无人归属。
- `agent lane`：使用标签表达执行通道，不用虚拟账号冒充 assignee。
- Agent 标签：
  - `agent-a`：设计系统与 Figma 整理
  - `agent-b`：iOS 工程骨架与导航
  - `agent-c`：共享组件与设计 Token
  - `agent-d`：数据模型、Mock、API/Auth 适配层
  - `agent-e`：页面实现与状态页
  - `agent-f`：测试、国际化、验收
- 领域标签：
  - `design`
  - `ios`
  - `shared-ui`
  - `services`
  - `testing`
  - `i18n`
  - `infra`

### Priority 规则
- `High`
  - 阻塞后续开发的基础设施任务
  - 服务接线任务
  - 国际化与测试收口任务
- `Medium`
  - 页面静态实现任务
  - 共享组件提取任务
  - 文档回填与阶段收口任务

### 分支与提交流程
- 分支命名优先使用 Linear 自动生成的 branch name。
- 一个 Linear issue 对应一个分支与一个 PR。
- `push` 前必须通过本地 `pre-push` 门禁。
- 合并前必须通过 GitHub Actions 与分支保护。

### 建议 Agent 编组
- Agent A：设计系统与 Figma 整理
- Agent B：iOS 工程骨架与导航
- Agent C：共享组件与设计 Token
- Agent D：数据模型、Mock、API 适配层
- Agent E：页面实现（Today / Map / Alerts / Profile）
- Agent F：测试、国际化、验收

### Wave 0：立即可并行启动
- [x] T01 - 整理 Figma 页面结构与命名
  - 建议负责人：Agent A
  - 预计时长：0.5 天
  - 依赖：无
  - 输出物：统一页面分组、画板命名、封面说明、组件页入口
  - 主要边界：只动 Figma，不改代码
  - 成功标准：Figma 内形成 `00 Cover / 01 Foundations / 02 Mobile Core / 03 Main Screens / 04 States & Overlays`
  - 完成说明：已新建整理版真源文件 `cf5PnK1WSe5IYRQNGT81fu`，旧文件 `l629AeywT4tJwH7B3F2EJM` 降级为历史素材源

- [x] T02 - 回写 UI 文档与 Figma 命名映射
  - 建议负责人：Agent A
  - 预计时长：0.5 天
  - 依赖：T01
  - 输出物：更新 `02-ui-ux-spec.md` 和 `ui/02a-02d` 文档中的页面命名与组件命名
  - 主要文件：`/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`、`/Users/ninesun/projects/arapp/docs/plans/phase-1/ui/`
  - 成功标准：文档中的页面名、组件名与 Figma 完全一致
  - 完成说明：已回写新真源 `cf5PnK1WSe5IYRQNGT81fu`、页面映射 `03 Main Screens / ...` 与共享组件命名规则

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


## [Phase 2 - Supabase 真联调与配置治理] (优先级: 高)
创建时间：2026-03-07 19:20
更新时间：2026-03-08 20:19 - 完成 P2-14（auth/exchange 函数部署与强制门禁验证）

### 真源与原则
- 设计真源：`/Users/ninesun/projects/arapp-worktrees/phase2-kickoff/docs/plans/2026-03-07-phase-2-supabase-integration-design.md`
- Phase 2 目标：真实 Supabase Auth、真实 Edge Functions API、配置治理、联调测试。
- 任何新增第三方依赖安装前必须先确认。
- 仓库只保留 sample 配置，不提交真实密钥。

### 启动任务
- [x] P2-01 - 建立环境配置契约与 sample 配置文件 ✅ (完成时间：2026-03-07 21:54)
  - 成功标准：支持 mock/real 双模式切换；仓库内无真实密钥。
  - 完成说明：
    - 新增 `AppEnvironment` 统一配置解析：运行模式、Edge、Supabase 配置。
    - 新增 sample 配置模板与说明文档：`App/Environment/AppEnvironment.sample.env`、`App/Environment/README.md`。
    - 更新 `.gitignore`：忽略本地环境文件，避免真实密钥入库。
    - Today/Map/Alerts 的 live 配置读取已改为统一入口，不再散落读取进程环境变量。
    - 测试通过：`bash scripts/test-ios.sh`（单元 + UI 冒烟）。

- [x] P2-02 - 建立运行模式切换与依赖注入装配 ✅ (完成时间：2026-03-07 22:00)
  - 成功标准：切换模式不改业务页面代码；Today/Map/Alerts/Profile 可从统一注入点读取依赖。
  - 完成说明：
    - 新增 `AppDependencies` 作为统一装配入口，按环境创建 Auth 与页面模型依赖。
    - `AppState` 新增统一持有：`dependencies`、`today/map/alerts` 模型、`authFlowModel`。
    - `AppRootView` 改为从 `AppState` 注入 Today/Map/Alerts/Profile/Login 所需依赖对象。
    - Today/Map/Alerts 模型改为支持显式 `environment` 注入，默认模式从环境推导。
    - 测试通过：`bash scripts/test-ios.sh`（单元 + UI 冒烟）。

- [x] P2-03 - 梳理 Supabase Auth 接入设计与回调路径 ✅ (完成时间：2026-03-07 22:20)
  - 成功标准：明确 Provider 登录到业务会话链路；确认回调 scheme/Info.plist 约束与错误降级策略。
  - 完成说明：
    - 新增设计文档：`docs/plans/2026-03-07-p2-03-supabase-auth-callback-design.md`。
    - 回调配置契约扩展：新增 `ARAPP_SUPABASE_REDIRECT_HOST`、`ARAPP_SUPABASE_REDIRECT_PATH`。
    - `Info.plist` 与 `project.yml` 增加回调 scheme 注册与默认值，避免 P2-04 前配置散落。
    - 新增 `SupabaseAuthCallbackParser` 与单元测试，覆盖成功/取消/错误/无效回调四类场景。

- [x] P2-04 - 接入真实 Supabase AuthService ✅ (完成时间：2026-03-07 23:10)
  - 成功标准：`AuthServicing` 在 real 模式下走 Supabase 真实现，支持读取会话、Provider 登录、登出，并保留 Mock 回退。
  - 完成说明：
    - `project.yml` 已接入 `supabase-swift`，主 target 依赖 `Auth` 产品，保持 Auth 能力最小引入。
    - `SupabaseAuthConfiguration` 补充 `anonKey`，`AppDependencies` 完成 real 模式下的完整注入。
    - `SupabaseAuthService` 从占位实现切换为真实实现：`currentSession`、`signIn`、`signOut`。
    - 新增 `exchangeSession(fromCallbackURL:)`，将 P2-03 的 callback parser 与 `authClient.session(from:)` 串接，作为 P2-05 页面接线桥接点。
    - 错误映射补齐：登录取消、Provider 不可用、session 缺失等场景统一收敛到 `AuthServiceError`。
    - 验证通过：`bash scripts/test-ios.sh`、`bash scripts/ci-local.sh`（单元 + UI 冒烟 + 本地门禁）。

- [x] P2-05 - 完成 Auth 会话交换与 Profile/Login 接线 ✅ (完成时间：2026-03-08 10:42)
  - 成功标准：OAuth 回调进入 App 后可完成会话交换并刷新登录态；Profile/Login 与会话状态联动一致；非认证 URL 不误处理。
  - 完成说明：
    - 新增 `AuthCallbackSessionExchanging` 协议，明确 Auth 服务层的“回调 URL -> 会话”能力边界。
    - `SupabaseAuthService` 显式实现该协议，复用 P2-04 的 `exchangeSession(fromCallbackURL:)`。
    - `AuthFlowModel` 新增 `handleOAuthCallback(_:)`：成功写入登录会话，`invalidCallback` 忽略，取消/失败进入错误态并保留匿名兜底。
    - `AppRootView` 增加 `.onOpenURL` 接线，处理 OAuth 回调；登录成功后自动回到主栈并聚焦 Profile tab。
    - 新增单测 `AuthFlowModelTests`，覆盖回调成功、无关 URL 忽略、回调失败错误展示三类路径。
    - 验证通过：`bash scripts/test-ios.sh`、`bash scripts/ci-local.sh`（25 单测 + 1 UI 冒烟 + 本地门禁）。

- [x] P2-06 - 建立真实 API 配置与请求装配 ✅ (完成时间：2026-03-08 14:32)
  - 成功标准：统一 API 配置模型、请求装配层、错误分类入口落地；Today/Map/Alerts 复用统一 live client 装配。
  - 完成说明：
    - 新增 `EdgeFunctionsRequestConfiguration`：统一管理 `baseURL / token / timeout / defaultHeaders`。
    - 新增 `LivePollenClientFactory`：统一把 `AppEnvironment` 映射为 live API client（含 `X-ArApp-Client` 默认头）。
    - `APIEndpoint` 请求构造改为基于统一配置装配，补齐请求超时和默认头注入。
    - `AppDependencies` 统一向 Today/Map/Alerts 注入同一套 live client factory，移除页面层重复拼装逻辑。
    - 新增 `ARAPP_EDGE_TIMEOUT_SECONDS` 配置契约，并补充 `AppEnvironment` 解析与文档说明。
    - 新增单测：`LivePollenClientFactoryTests`；`AppEnvironmentTests` 增补 timeout 解析覆盖。
    - 验证通过：`bash scripts/test-ios.sh`（30 单测 + 1 UI 冒烟）。

- [x] P2-07 - Today 接入真实 summary/forecast ✅ (完成时间：2026-03-08 14:48)
  - 成功标准：Today 真实接口成功展示；失败路径可见且可重试。
  - 完成说明：
    - Today live client 构造统一复用 `LivePollenClientFactory`，与 Map/Alerts 保持同一配置入口。
    - Today client 路径补齐成功态、forecast 空态、非重试失败态覆盖，确保真实接口返回在 UI 状态机上可见。
    - `APIClientError` 新增 `isRetryable` 语义，Today 失败态按错误类型映射可重试标记。
    - 验证通过：`bash scripts/test-ios.sh`（33 单测 + 1 UI 冒烟）、`bash scripts/ci-local.sh`（本地 CI 全部通过）。

- [x] P2-08 - Map 接入真实 suggestions/sources ✅ (完成时间：2026-03-08 15:14)
  - 成功标准：Map 真实接口成功展示；失败路径可见且可重试。
  - 完成说明：
    - Map client 路径补齐成功态与失败态验证，覆盖 `summary/suggestions/sources` 联合装配结果。
    - `MapScreenModel` 失败态重试语义与 `APIClientError.isRetryable` 对齐，避免非重试错误误标可重试。
    - 新增 `MapScreenModelTests` client 用例：成功态、网络失败可重试、非重试状态失败。
    - 验证通过：`bash scripts/test-ios.sh`（36 单测 + 1 UI 冒烟）、`bash scripts/ci-local.sh`（本地 CI 全部通过）。

- [x] P2-09 - Alerts 接入真实 subscriptions ✅ (完成时间：2026-03-08 15:26)
  - 成功标准：Alerts 真实接口读写可用；错误可见并可恢复。
  - 完成说明：
    - `AlertsScreenModel.reload()` 失败处理统一走 `failureState(for:)`，错误展示语义保持一致。
    - `APIClientError` 分支的重试标记改为 `apiError.isRetryable`，避免误标记不可重试错误。
    - `updateEnabled` / `updateThreshold` 改为异步写回，client 模式下通过 `persistSubscription(_:)` 调用 `upsertAlertSubscription`。
    - `AlertsView` 的开关与阈值变更改为 `Task { await ... }`，与异步写回链路对齐。
    - 新增 `AlertsScreenModelTests` client 用例，覆盖成功态、可重试/不可重试失败态、写回失败与恢复路径。
    - 验证通过：`bash scripts/test-ios.sh`（41 单测 + 1 UI 冒烟）、`bash scripts/ci-local.sh`（本地 CI 全部通过）。

- [x] P2-10 - 联调测试与发布文档收口 ✅ (完成时间：2026-03-08 11:26)
  - 成功标准：关键真实链路有复现步骤；测试证据、配置说明、发布检查项文档齐全；本地门禁通过。
  - 完成说明：
    - 测试验收文档补充 Phase 2 联调快照与新增回归点：
      - `docs/plans/phase-1/10-testing-acceptance-plan.md`
    - 发布 runbook 补充 Phase 2 发布就绪清单（配置、门禁、人工检查、Auth 回滚）：
      - `docs/plans/phase-1/11-release-observability-runbook.md`
    - 新增 Phase 2 交付记录：
      - `docs/plans/2026-03-08-phase-2-delivery-record.md`
    - 验证通过：`bash scripts/test-ios.sh`、`bash scripts/ci-local.sh`。

- [x] P2-11 - RLS 越权自动化脚本与执行入口（Linear: `NIN-39`）✅ (完成时间：2026-03-08 18:52)
  - 成功标准：RLS-001/RLS-002 可自动校验并输出 PASS/FAIL；缺少凭据时给出可追踪 SKIP 原因。
  - 完成说明：
    - 已新增 `scripts/test-rls.py`（A/B 双账号越权读写校验）与 `scripts/test-rls.sh`，并接入 `scripts/ci-local.sh`。
    - 已在 Supabase 真实环境执行最小 schema/RLS 迁移：`locations`、`devices`、`alert_subscriptions`（含 policy、grant、trigger）。
    - 已执行强制校验：`ARAPP_RLS_REQUIRED=1 bash scripts/test-rls.sh`，结果 `RLS-001`/`RLS-002` 均 PASS。
    - 发布建议：CI/预发持续启用 `ARAPP_RLS_REQUIRED=1`，将越权校验作为阻断门禁。

- [x] P2-12 - Provider 手工验收留痕模板与发布清单（Linear: `NIN-40`）✅ (完成时间：2026-03-08 19:04)
  - 成功标准：三方 Provider 的手工验收步骤、通过标准、截图/日志留痕路径固定，发布前可直接执行。
  - 完成说明：
    - 新增 `docs/plans/phase-1/13-provider-acceptance-checklist.md`，覆盖 Google/GitHub/Apple 成功/取消场景矩阵。
    - 新增统一失败记录模板与证据目录约定，避免验收口径分散。
    - `11-release-observability-runbook.md` 已互链 Provider 验收清单。

- [x] P2-13 - auth/exchange 联调自动化脚本与 CI 可选入口（Linear: `NIN-41`）✅ (完成时间：2026-03-08 19:04)
  - 成功标准：支持缺省 SKIP、强制失败模式；能校验 `/v1/auth/exchange` 的 2xx 与契约字段完整性。
  - 完成说明：
    - 新增 `scripts/test-auth-exchange.py`、`scripts/test-auth-exchange.sh`。
    - `scripts/ci-local.sh` 新增 `auth/exchange 联调测试（可选）` 步骤。
    - `10-testing-acceptance-plan.md` 已补充执行命令、环境变量、`ARAPP_AUTH_EXCHANGE_REQUIRED=1` 强制口径。
    - 真实环境实测：`ARAPP_EDGE_BASE_URL=https://zlcnljlbuimlzhwpyrlj.supabase.co/functions/v1` 下当前返回 `404 NOT_FOUND`（后端函数未部署）；非强制模式按预期 SKIP，强制模式按预期阻断。

- [x] P2-14 - 部署 auth/exchange Edge Function 并完成强制门禁验证（Linear: `NIN-42`）✅ (完成时间：2026-03-08 20:19)
  - 成功标准：`POST /v1/auth/exchange` 返回 2xx 且含 `request_id/code/message/retryable`；`ARAPP_AUTH_EXCHANGE_REQUIRED=1 bash scripts/test-auth-exchange.sh` 在预发可通过。
  - 完成说明：
    - 已安装 Supabase CLI（`2.75.0`），并初始化本地 `supabase/` 工程目录。
    - 已实现并部署 Edge Function：`supabase/functions/v1/index.ts`（承载 `/v1/auth/exchange` 路由并返回契约字段）。
    - 已新增部署脚本：`scripts/deploy-auth-exchange.sh`，支持优先使用 `supabase login` 会话授权。
    - 已执行强制校验：`ARAPP_AUTH_EXCHANGE_REQUIRED=1 bash scripts/test-auth-exchange.sh`，结果 `PASS AUTH-EXCHANGE-001`。
    - 风险备注：当前 `supabase/config.toml` 对 `functions.v1` 使用 `verify_jwt=false`（函数内保留 Bearer 头检查）；建议后续专项恢复网关级 JWT 校验并补充回归。
