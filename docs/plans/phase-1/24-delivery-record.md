# 24 交付记录（2026-03-07）

## 1. 目标
- 记录 Phase 1 当前已实现范围，作为设计、实现、测试三份真源的交汇点。

## 2. 已完成任务
- `T03` 初始化 iOS 工程骨架与目录约定
- `T04` 定义设计 Token 到 SwiftUI 的映射
- `T05` 建立领域模型与 Mock 数据
- `T06` 建立测试骨架与基线校验
- `T07` 实现 Today 页面静态骨架
- `T08` 实现 Map 页面静态骨架
- `T09` 实现 Alerts 页面静态骨架
- `T10` 实现 Profile 页面静态骨架
- `T11` 实现 Auth / Login 页面静态骨架
- `T12` 实现 Onboarding 静态骨架
- `T13` 提取共享组件第一批
- `T14` 提取共享组件第二批
- `T15` 实现状态页与弹层
- `T16` 建立 Supabase Auth 接口适配层
- `T17` 建立 Pollen API Client 与错误模型
- `T18` Today 页面接入 Mock / Client 双模式
- `T19` Map 页面接入 Mock / Client 双模式
- `T20` Alerts 页面接入 Mock / Client 双模式
- `T21` Profile / Auth 页面接入 Auth 假流程
- `T22` 接入双语文案与格式化
- `T23` 补齐单元测试与 UI 冒烟测试
- `T24` 开发收口与文档回填

## 3. 当前实现范围
- SwiftUI 主流程已具备：
  - Today
  - Map
  - Alerts
  - Profile
  - Login
  - Onboarding
- 数据层已具备：
  - Mock API Client
  - Edge Functions API Client
  - Supabase Auth 适配层
- 国际化已具备：
  - `zh-Hans`
  - `en`
  - 应用内语言切换
  - 日期/时间/百分比统一格式化

## 4. 当前测试结果
- 本地统一命令：`bash scripts/ci-local.sh`
- 单元测试：10 个通过
- UI 冒烟测试：1 个通过
- iOS 构建：通过

## 5. 当前未完成项
- 真实 Supabase 环境联调
- RLS 自动化验证
- API contract fixture 自动化

## 6. 备注
- 当前所有结果均为本地提交状态，尚未统一 push。
- 未改动用户原始研究文件与 Excel 文件。
