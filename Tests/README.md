# Tests Baseline

## 目标
- 为 `ArApp` 提供最小单元测试与 UI 测试命名基线。
- 当前阶段先落测试目录和最小 smoke case，并通过 `T03` 的工程骨架接入 Xcode target。

## 后续动作
1. 保持 `ArAppTests` 与 `ArAppUITests` 和 `project.yml` 对齐
2. 在页面实现进入真实状态测试后补齐更多用例
3. 通过 `scripts/test-ios.sh` 执行 `xcodegen + xcodebuild test`
