# Sidelit

**专注当前屏幕，调暗其他屏幕。**

轻量 macOS 菜单栏工具，根据正在操作的窗口自动切换当前屏幕，其他屏幕随之调暗。不跟随鼠标位置，不读取输入内容，不联网，也不修改显示器硬件亮度。

从 [Releases](https://github.com/HakurouKen/focus-screen/releases/latest) 下载 Universal 包，支持 Apple Silicon 和 Intel。解压后将应用放入「应用程序」。

## 构建与运行

需要 macOS 13+ 和 Xcode Command Line Tools（`xcode-select --install`）。

```sh
./scripts/build.sh
open dist/Sidelit.app
```

首次使用：点击菜单栏图标 →「授予辅助功能权限…」，在系统设置中允许 Sidelit。若列表中没有应用，可手动添加 `dist/Sidelit.app`。

## 使用

- **调暗其他屏幕**：勾选启用，取消勾选暂停。
- **调暗程度**：默认 20%，数值越大越暗；0% 不调暗，100% 全黑。变暗的屏幕仍可点击，切换后恢复原有亮度。设置自动保存。
- **登录时自动启动**：建议先将应用放到 `/Applications/Sidelit.app`，再开启此选项；若显示「待允许」，按菜单提示进入系统设置。

打开菜单或悬停图标可查看运行状态。单屏、未授权或无法确定当前屏幕时，不会调暗任何屏幕。

## 注意事项

- 应用使用 ad-hoc 签名，未经过 Apple 公证；首次打开可能需要在「系统设置 → 隐私与安全性」中允许。更新后若授权失效，请在辅助功能列表中移除旧项目并重新添加。
- 从 Focus Screen 更新时，先退出旧应用。原有设置保留，旧应用不会自动删除；授权和登录项可能需要重新配置。
- 支持多屏、跨桌面和原生全屏；特殊应用及系统界面的表现需实际确认。

## 开发

运行测试：`./scripts/test.sh`。

替换图标：`./scripts/generate-icons.sh path/to/icon.png`（也支持 JPG/JPEG）。使用正方形图片，建议 1024×1024 的透明 PNG；输出为 `Resources/AppIcon.icns`。不传参数时使用 `Resources/AppIcon.png`，普通构建无需重新转换。

## 版本与发布

`VERSION` 是唯一版本来源，格式为 `0.1.0`；应用菜单显示当前版本。本地构建默认为当前架构，构建号默认为 1，可通过 `SIDELIT_BUILD_NUMBER` 指定；CI 使用运行编号。运行 `./scripts/package.sh` 可生成 Universal ZIP 和 SHA-256 校验文件，`./scripts/verify-package.sh` 验证解压后的产物。

修改并提交 `VERSION`，推送到 `main` 后发布：

```sh
gh workflow run release.yml --ref main -f version=0.1.0
gh run watch
```

工作流在两种架构上测试、构建并验证；全部成功后，为触发时的提交创建 `v0.1.0` tag 并直接发布附件及更新说明。普通 push／PR 只验证，不发布。版本输入不一致、从非 main 发起或版本已存在时会拒绝发布；若上传失败留下草稿，检查该草稿后再处理，不覆盖已发布版本。
