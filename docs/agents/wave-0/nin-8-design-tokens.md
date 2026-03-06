# NIN-8 / T04 开工说明

## 任务
- 定义设计 Token 到 SwiftUI 的映射

## 输出物
- 颜色 Token
- 字体 Token
- 间距、圆角、阴影 Token
- 风险等级视觉映射

## 目录边界
- 仅允许修改：
  - `SharedUI/Theme/`
  - `SharedUI/Foundation/`
- 若 `T03` 尚未落地，可先产出纯 Swift 文件结构设计草案

## 禁止项
- 不实现业务页面
- 不改 API、模型、测试
- 不在具体 Feature 中写死颜色和字号

## 设计约束
- 以 `01 Foundations / System` 为视觉真源
- 命名优先使用：
  - `AppColor`
  - `AppTypography`
  - `AppSpacing`
  - `AppRadius`
  - `RiskPalette`

## 完成标准
- 能覆盖首页、地图、提醒、我的四个主页面的基础视觉需求
- 与 `system.html`、Figma Foundations 页一致
- 不依赖具体业务状态

## 参考
- `/Users/ninesun/projects/arapp/docs/plans/phase-1/02-ui-ux-spec.md`
- `https://www.figma.com/design/cf5PnK1WSe5IYRQNGT81fu`

## 分支
- `codex/nin-8-design-tokens`
