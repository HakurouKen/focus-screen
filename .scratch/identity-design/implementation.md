# Sidelit 品牌与文案实施记录

## 已完成

- 应用包、可执行文件、显示名称、菜单与登录项说明统一使用 Sidelit。
- 接入 A 方案正式应用图标，包含 10 个标准尺寸；保留 Swift 矢量源文件和生成脚本。
- 菜单栏以原生 18 pt 模板图像绘制固定双屏符号，辅助功能名称为 Sidelit，状态由菜单与 tooltip 表达。
- 统一调暗相关文案，滑块悬停说明 0%／100% 含义，README 更新构建、安装与旧版本更名说明。
- 保留 bundle identifier、配置键、调暗行为与登录注册逻辑。

## 验证

- `./scripts/test.sh`：屏幕归属、刷新调度、配置持久化与边界、登录项模拟、滑块与遮罩测试均通过，Info.plist 校验通过。
- `./scripts/build.sh`：成功生成并签名 `dist/Sidelit.app`。
- `codesign --verify --deep --strict --verbose=2 dist/Sidelit.app`：通过。
- 应用包内图标与源资源 SHA-256 一致；用 iconutil 解包验证 10 个标准尺寸齐全。
- 查看正式 256 px 应用图标；使用临时原生 AppKit 预览程序检查模板属性、18 pt 尺寸、辅助功能名称和 Aqua／Dark Aqua 渲染。
- Shell 语法、Git 空白检查与代码差异复核通过；用户可见旧品牌只保留在 README 的升级说明中。

## 尚未实测

- 安装到固定路径后的 Finder 图标缓存、辅助功能列表和登录项显示。
- 真实 macOS 菜单栏不同缩放下的显示与交互、跨屏及全屏切换。
- 真实登录注册、重新登录启动、旧版本授权或注册迁移。

本轮未替换已安装应用或修改真实登录项。现有 ad-hoc 签名可能需要用户重新授权。

## 工作区

- 原工作区：`/Users/leroy/Documents/projects/focus-screen`，分支 `main`。
- 实施 worktree：`/Users/leroy/Documents/projects/focus-screen/.codex/worktrees/sidelit-branding`，分支 `feat/sidelit-branding`。
- 用户确认后，实施提交 `b01edc3` 已通过 fast-forward 合并到原工作区的 `main`。实施 worktree 保留。
