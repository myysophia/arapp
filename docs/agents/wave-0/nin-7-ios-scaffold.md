# NIN-7 / T03 开工说明

## 任务
- 初始化 iOS 工程骨架与目录约定

## 输出物
- SwiftUI App 入口
- `TabView` 骨架
- 目录结构占位
- 可编译运行的空页面

## 目录边界
- 允许新建：
  - `App/`
  - `Features/`
  - `SharedUI/`
  - `Models/`
  - `Services/`
  - `Tests/`
- 允许新建：
  - `project.yml` 或等价工程配置
  - `.xcodeproj` 如需要

## 禁止项
- 不接真实 API
- 不接 Supabase
- 不实现复杂页面细节
- 不改 `docs/plans/phase-1/` 除非补最小实现备注

## 设计约束
- 导航结构固定：
  - `Today`
  - `Map`
  - `Alerts`
  - `Profile`
- 入口页允许预留 `Auth` 与 `Onboarding` 路由
- 页面先用占位 View，不引入真实状态管理

## 完成标准
- 可在模拟器启动
- 4 个 Tab 可见
- 登录页与 Onboarding 有基本路由入口
- 目录结构与 `TODO.md` 保持一致

## 参考
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/ui/02a-home-screen-spec.md`

## 分支
- `codex/nin-7-ios-scaffold`
