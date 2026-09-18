# 应用名称、图标与调暗文案统一

Label: wayfinder:map
Status: open

## Destination

确定可交付实现的统一设计规范：英文应用名、应用与菜单栏图标方向，以及覆盖现有界面的中文调暗文案。最终选择通过具体方案与用户讨论确定。

## Notes

- 本地图只规划和形成决策，不执行应用改名、绘制正式资产或修改应用代码。
- 用户已确认：允许整体重设计；以「专注当前屏幕」为核心；英文品牌名搭配中文界面；双屏明暗图标，菜单栏为简化单色版；保留 Focus Screen 为候选，同时探索新名称。这些是建图前的范围与偏好，尚非最终设计。
- 实际行为：当前焦点窗口所在屏幕保持原样，其他屏幕叠加黑色遮罩；不提升硬件亮度。0% 表示无遮罩，100% 表示全黑。
- 后续会话使用 wayfinder、grilling 和 domain-modeling；视觉对比使用 prototype；外部事实调查使用 research。研究参考 HazeOver，具体设计仍需独立形成。
- tracker 采用本地 Markdown；子票置于 issues/。Status: open 为未领取，claimed 为已领取，resolved 为已关闭。Blocked by 记录依赖，按编号查询未被阻塞且未领取的票。
- 研究资产分支：research/identity-hazeover；worktree：.codex/worktrees/identity-research。资产会复制到本目录供直接阅读，原分支作为来源保留。
- [当前名称、图标与文案盘点](current-state.md) 提供讨论的源码基线；它是事实记录，不是设计决策。

## Decisions so far

- [HazeOver 如何表达专注、调暗与视觉识别](issues/01-hazeover-reference.md) — 官方参考已核验；借鉴表达层级，同时明确本项目按屏幕调暗的范围。

## Not yet specified

- 名称和视觉方案选定后，复查 Finder、系统授权列表、登录项和说明文档等触点的具体呈现要求。
- 图标小尺寸对比后，可能需要补充启用、暂停及不可用状态的视觉区分规则。

## Out of scope

- 应用代码修改、正式图标资产制作、安装部署与发布。
- 增加按窗口调暗、快捷键、动画等功能，或改变当前按屏幕调暗的行为。
- 商标注册与法律层面的名称可用性保证。
