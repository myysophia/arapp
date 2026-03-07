# Smoke Test Plan Notes

## Unit
- `AppBootSmokeTests`
  - 验证 Tab 数量与产品规格一致

## UI
- `AppLaunchSmokeTests`
  - 后续替换为真正的启动、Tab 可见、登录入口可见测试

## 阻塞
- 依赖 `T03` 生成工程和 `ArApp` target
- 依赖完整 Xcode 安装与 `xcodebuild` 可用
