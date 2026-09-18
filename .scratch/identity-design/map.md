# 应用名称、图标与调暗文案统一

Label: wayfinder:map
Status: resolved

## Destination

确定可交付实现的统一设计规范：英文应用名、应用与菜单栏图标方向，以及覆盖现有界面的中文调暗文案。最终选择通过具体方案与用户讨论确定。

## Notes

- 本地图只规划和形成决策，不执行应用改名、绘制正式资产或修改应用代码。
- 用户已确认：允许整体重设计；以「专注当前屏幕」为核心；英文品牌名搭配中文界面；双屏明暗图标，菜单栏为简化单色版。具体设计决定见下方票据索引。
- 实际行为：当前焦点窗口所在屏幕保持原样，其他屏幕叠加黑色遮罩；不提升硬件亮度。0% 表示无遮罩，100% 表示全黑。
- 后续会话使用 wayfinder、grilling 和 domain-modeling；视觉对比使用 prototype；外部事实调查使用 research。研究参考 HazeOver，具体设计仍需独立形成。
- tracker 采用本地 Markdown；子票置于 issues/。Status: open 为未领取，claimed 为已领取，resolved 为已关闭。Blocked by 记录依赖，按编号查询未被阻塞且未领取的票。
- 研究资产分支：research/identity-hazeover；worktree：.codex/worktrees/identity-research。资产会复制到本目录供直接阅读，原分支作为来源保留。
- [当前名称、图标与文案盘点](current-state.md) 提供讨论的源码基线；它是事实记录，不是设计决策。
- 命名偏好：产品名可以使用模糊意象或代指，功能说明由副标题与界面文案承接。命名讨论及决定见下方命名票。

## Decisions so far

- [HazeOver 如何表达专注、调暗与视觉识别](issues/01-hazeover-reference.md) — 官方参考已核验；借鉴表达层级，同时明确本项目按屏幕调暗的范围。
- [对比并确定英文应用名](issues/02-name-direction.md) — 确定为 Sidelit，以舞台侧光为品牌意象。
- [确定调暗操作、强度与状态的统一中文文案](issues/03-copy-language.md) — 保留「调暗」，统一开关、程度、当前屏幕及各状态文案。
- [对比并确定双屏明暗图标方案](issues/04-icon-comparison.md) — 采用 A 并排双屏；菜单栏使用固定单色图形，运行状态交由文字说明。
- [确定 Sidelit 在系统与文档中的呈现规范](issues/05-identity-touchpoints.md) — 对外统一 Sidelit，保留内部身份与设置；实施验收清单已确认。

## Not yet specified

无。全部子票已解决，规划可交付实施。

## Out of scope

- 应用代码修改、正式图标资产制作、安装部署与发布。
- 增加按窗口调暗、快捷键、动画等功能，或改变当前按屏幕调暗的行为。
- 商标注册与法律层面的名称可用性保证。
