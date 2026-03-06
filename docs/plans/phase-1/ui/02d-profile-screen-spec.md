# 02D 我的页单页规格（Profile Screen Spec）

## 1. 目标与成功标准
- 目标：集中承载登录、偏好设置、隐私与数据管理、来源与免责声明，让用户能快速理解账户状态和可管理内容。
- 成功标准：未登录用户能清楚知道登录价值，已登录用户能在单页内完成语言、单位和隐私操作。

## 2. 范围与非范围
- 范围：账户卡、登录按钮组、偏好设置、隐私与数据、关于与来源说明。
- 非范围：个人资料编辑、头像上传、订阅管理、客服反馈系统。

## 3. 输入/输出与接口
- 输入接口：
  - `GET /v1/auth/me`
  - `PATCH /v1/user/preferences`
  - `POST /v1/auth/logout`
- 输入字段：
  - `user_id`
  - `providers`
  - `locale`
  - `unit_system`
  - `tz`
  - `is_anonymous`
- 输出：登录状态展示、偏好更新结果、退出登录结果。

## 4. 数据模型与约束
- 登录 provider 固定支持 `google/github/apple`。
- 语言首版支持 `zh-Hans`、`en`。
- 单位首版支持 `metric`、`imperial`。
- 删除数据入口不直接在当前页执行数据库删除，必须经过二次确认流程。

## 5. 异常与降级
- 登录失败：停留当前页，按钮恢复可点击，并提示失败原因。
- 偏好保存失败：回退到上次成功状态，显示重试提示。
- 登出失败：保持当前登录状态，展示错误 toast。
- 无网络：可查看当前偏好缓存，禁用修改后的立即同步反馈。

## 6. 安全与合规
- 登录按钮不得误导为唯一入口，页面首屏需明确“基础功能无需登录”。
- 删除数据为危险操作，必须二次确认。
- 隐私政策、数据来源、免责说明必须从“我的”页直达。

## 7. 埋点与可观测性
- `view_profile`
- `tap_login_provider`
- `auth_success`
- `auth_fail`
- `change_locale`
- `change_unit_system`
- `tap_delete_data`
- `tap_logout`
- 监控：登录成功率、偏好保存成功率、删除意图触发率。

## 8. 测试与验收
- 未登录态和已登录态视觉层级差异清晰。
- 三方登录按钮状态正确，loading/error 反馈一致。
- 切换语言后页面即时刷新。
- 单位切换后相关展示页数值格式正确联动。
- 危险操作二次确认正确触发。

## 9. 依赖与里程碑
- 依赖：认证设计、i18n 规格、隐私合规文档、API 偏好接口。
- 里程碑：该文档通过后可直接进入“我的”页高保真与开发。

## 10. 假设与默认值
- 未登录为默认状态。
- 登录成功后不跳转新页面，仅刷新当前页。
- 默认语言跟随系统，默认单位为 `metric`。

## 11. 页面布局
### 11.1 首屏层级
- 页面标题：`我的`
- 账户状态卡：头像占位、主标题、副标题。
- 登录按钮组：Google、GitHub、Apple 三个按钮纵向排列。
- 偏好设置区：语言、单位、默认城市。

### 11.2 第二屏层级
- 隐私与数据：权限状态、隐私政策、删除数据。
- 关于与来源：数据来源说明、非医疗建议、版本号。
- 登出按钮：仅登录态显示，位于页面底部危险操作区上方。

## 12. 组件拆分
### 12.1 AccountStatusCard
- props：`isAnonymous`、`displayName`、`providers[]`

### 12.2 AuthButtonGroup
- props：`availableProviders[]`、`loadingProvider`、`onTapProvider`

### 12.3 PreferenceRow
- props：`titleKey`、`valueLabel`、`onTap`

### 12.4 PrivacyMenuCard
- props：`permissionStates`、`onOpenPolicy`、`onOpenDeleteFlow`

### 12.5 AboutCard
- props：`versionLabel`、`sourceSummaryKey`、`disclaimerKey`

### 12.6 DangerActionButton
- props：`titleKey`、`style`、`onTap`

## 13. 交互规则
- 未登录态下账户卡副标题说明登录价值，如“登录后可同步提醒设置”。
- 已登录态下按钮组替换为 provider 绑定状态标签，不再继续展示登录主按钮。
- 偏好修改后即时更新 UI，并异步提交保存。
- 删除数据点击后进入确认弹层，不在本页直接执行。

## 14. 状态机
- `anonymous -> auth_in_progress -> authenticated`
- `auth_in_progress -> auth_failed -> anonymous`
- `authenticated -> logging_out -> anonymous`
- `ready -> preference_saving -> ready`
- `ready -> delete_confirming`

## 15. 文案与视觉规则
- 登录按钮等宽等高，Apple 按钮保持系统视觉规范。
- 偏好设置行使用列表样式，不使用主按钮风格。
- 删除数据按钮使用危险色描边，不与登出按钮混淆。
- “基础功能无需登录”文案必须在未登录首屏可见。

## 16. Figma 搭建建议
- Frame：iPhone 15 Pro 主稿。
- 图层命名：
  - `Profile/Header`
  - `Profile/AccountStatusCard`
  - `Profile/AuthButtonGroup`
  - `Profile/PreferenceSection`
  - `Profile/PrivacySection`
  - `Profile/AboutSection`
  - `Profile/DangerActions`
