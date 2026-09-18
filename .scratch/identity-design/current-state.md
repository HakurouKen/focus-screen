# 当前名称、图标与文案盘点

这是源码现状记录，不是已确定的新设计。基线：main 的 62c7359。

## 名称与图标

| 触点 | 当前内容 | 来源 |
| --- | --- | --- |
| 应用显示名称 | Focus Screen | Resources/Info.plist 的 CFBundleName |
| 应用包与可执行文件 | FocusScreen.app / FocusScreen | scripts/build.sh、Resources/Info.plist |
| 菜单栏图标 | 系统符号 display.2 | Sources/main.swift |
| 图标辅助功能名称 | Focus Screen | Sources/main.swift |
| 退出菜单 | 退出 Focus Screen | Sources/main.swift |
| 登录项提示 | 请在系统设置的登录项中允许 Focus Screen。 | Sources/main.swift |
| README 授权说明 | FocusScreen | README.md |
| 独立应用图标 | Resources 仅有 Info.plist；未声明应用图标，也没有构建图标复制步骤 | Resources/、scripts/build.sh |

名称规范需区分品牌显示名称与技术标识。后续展示名称变更，不自动意味着应修改 bundle identifier 或用户配置键。

## 调暗与状态

| 触点 | 当前文案 |
| --- | --- |
| 开关 | 启用屏幕调暗 |
| 滑块标题 | 调暗程度 |
| 滑块辅助功能描述 | 调暗程度，百分比 |
| 初始化 | 正在检测焦点… |
| 正常工作 | 焦点：<屏幕名称> |
| 单屏 | 单屏幕，无需调暗 |
| 暂停 | 已暂停 |
| 未授权 | 需要辅助功能授权 |
| 未获取焦点 | 未识别到焦点窗口 |
| 权限入口 | 授权辅助功能… |

来源：Sources/main.swift、Sources/DimmingMenuView.swift。菜单栏 tooltip 跟随当前状态文字。

当前滑块表示黑色遮罩强度：数值越大越暗。当前屏幕没有主动增亮操作；README 使用「恢复亮度」「保持所有屏幕明亮」等表达，需要在文案票中一并审视。暂停、单屏或未授权时，滑块仍可调整并保存。

## 评审时应覆盖的场景

- 名称在应用图标旁、退出菜单、权限说明中是否一致。
- 两个屏幕中的焦点切换时，图标隐喻是否仍然成立。
- 0%、100%、暂停与无焦点窗口时，文案是否准确。
- 单色菜单栏图标在深浅背景和小尺寸下是否清楚。
- 名称与图标是否误导用户以为应用会改变硬件亮度或只突出单个窗口。
