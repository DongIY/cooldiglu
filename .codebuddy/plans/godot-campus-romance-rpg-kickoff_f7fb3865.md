---
name: godot-campus-romance-rpg-kickoff
overview: 为一个基于 Godot 的校园恋爱日常 RPG 制定从零启动方案，聚焦题材收束、核心系统定义、工程初始化路径与多人协作落地方式。
todos:
  - id: benchmark-mvp
    content: 使用 [skill:game-product-analyst] 提炼竞品共性并锁定首版闭环
    status: completed
  - id: planning-docs
    content: 使用 [skill:patrick-star] 与 [skill:po-main] 产出GDD和协作规则
    status: completed
    dependencies:
      - benchmark-mvp
  - id: init-project
    content: 初始化 Godot 工程、GitHub 规范与资源目录骨架
    status: completed
    dependencies:
      - planning-docs
  - id: exploration-loop
    content: 实现校园地图探索、交互点、时段推进与主HUD
    status: completed
    dependencies:
      - init-project
  - id: relationship-events
    content: 实现好感度、剧情事件、CG展示与存档闭环
    status: completed
    dependencies:
      - exploration-loop
  - id: qa-export
    content: 使用 [subagent:code-explorer] 校验引用并完成 Windows 导出验收
    status: completed
    dependencies:
      - relationship-events
---

## User Requirements

- 制作一款小而美的校园恋爱日常 RPG，主题为校园生活、角色互动与关系成长，整体氛围清新、温暖、轻叙事。
- 玩法以校园地图探索为主，玩家可在校园区域中移动、调查点位、与角色对话，并通过选择和日常互动推动关系变化。
- 需要加入角色好感度系统，让不同互动、事件和阶段条件影响后续内容解锁，形成明确的成长反馈。
- 关键剧情要有高质量插画、立绘或事件图片作为表现强化，视觉上呈现精致、细腻、具有收藏感的“小而美”效果。
- 项目要支持多人协作与后续持续扩展，最终形成可在桌面端独立运行的完整版本。

## Product Overview

- 游戏核心体验是“探索校园日常 → 触发互动与事件 → 提升角色关系 → 解锁新剧情与插画 → 继续推进日常生活”。
- 首版应控制在单校园区域、少量核心角色、完整一条到数条角色线的可玩闭环，优先保证体验完整而不是内容铺得过大。
- 画面表现以 2D 校园地图、对话演出、人物立绘和关键事件插画为主，UI 风格简洁清晰，突出剧情阅读与关系成长反馈。

## Core Features

- 校园地图探索与场景交互
- 角色好感度成长与内容解锁
- 日程/日期推进下的剧情分支事件
- 关键剧情插画展示与图鉴收集
- 存档读档与多轮体验支持

## Tech Stack Selection

- 当前代码库状态：`d:/GodotGamedemo/EroticGame` 为空目录，未发现 `project.godot` 或既有工程文件，本次方案按“从零初始化工程”设计。
- 引擎：Godot 4.x，采用 2D 工作流
- 开发语言：GDScript
- 场景与 UI：Godot Scene System、Control、CanvasLayer、AnimationPlayer
- 数据组织：文本化 JSON 配置承载角色、事件、CG 图鉴等内容；地图与界面使用 `.tscn`
- 资源协作：GitHub 代码托管，CG/立绘/音频等大文件采用 Git LFS 管理
- 发布目标：Windows Desktop，后续生成 `.exe`

## Implementation Approach

- 采用“数据驱动事件系统 + 单校园地图闭环”的方法实现首版：先完成一个主校园场景、少量可互动点位、2 到 3 名核心角色、基础时间推进和一条完整角色线，确保探索、互动、好感度、剧情、CG、存档的核心循环完整可玩。
- 关键技术决策：
- 选择 GDScript 而非 C#：更贴近 Godot 原生工作流，适合小团队快速迭代，降低协作门槛。
- 选择 JSON 承载剧情与配置：便于策划、美术、程序并行编辑，减少二进制冲突，利于 GitHub 合并。
- 暂不引入第三方对话/任务插件：首版优先用轻量自研模块，避免插件依赖、升级兼容与技术债。
- 性能与可靠性：
- 事件系统基于 `map_id + point_id + time_slot` 建立索引，交互查询接近 O(1)，避免每次操作遍历全量事件。
- CG、立绘按需加载，关闭界面后释放引用，避免显存峰值抖动。
- 存档采用小体量 JSON 快照，复杂度随角色、标记和进度线性增长，首版数据量可控，读写成本低。

## Implementation Notes

- 复用 Godot 原生节点与资源系统，避免过早抽象成复杂框架；事件、关系、时间推进拆为独立系统，保持低耦合。
- 交互热路径不要做全表扫描：地图点位进入时只检查当前位置和当前时段相关事件；好感度变化后仅增量刷新可解锁项。
- 日志优先使用 Godot 内建错误与警告输出，错误信息只记录事件 ID、角色 ID、场景路径等必要上下文，避免输出大段剧情或资源内容。
- 首版保持单地图主循环，不做联网、不做复杂战斗、不做大规模资源流式系统，控制启动、内存和回归范围。
- GitHub 协作优先保证文本文件可合并；CG 等大资源通过 Git LFS 管理，避免仓库快速膨胀。

## Architecture Design

- **场景层**
- `main`：启动与场景切换入口
- `world`：校园地图、角色摆放、交互点
- `ui`：HUD、对话框、CG 图鉴、菜单
- **全局系统层**
- `GameState`：全局进度、日期时段、标记状态
- `SaveManager`：存档读档、槽位管理
- `TimeSystem`：日期与时段推进
- `AffectionSystem`：角色好感度读写与阈值判定
- `EventSystem`：事件索引、条件校验、效果执行
- **内容数据层**
- 角色配置：名称、立绘、初始关系、可解锁线
- 事件配置：触发点、触发条件、对话内容、效果、CG 关联
- 图鉴配置：CG 元数据、解锁条件、显示顺序
- **数据流**
- 玩家移动到点位或主动交互 → `EventSystem` 根据位置、时段和标记筛选事件 → 对话与选项执行 → `AffectionSystem`/`GameState` 更新 → UI 刷新 → `SaveManager` 存档

## Directory Structure

以下结构基于当前空仓库规划，为首版可玩闭环的首批文件落点：

```text
d:/GodotGamedemo/EroticGame/
├── project.godot                                  # [NEW] Godot 工程入口与全局配置；定义窗口、主场景、Autoload 注册，作为整个项目的基础。
├── README.md                                      # [NEW] 项目说明；写清启动方式、分支规范、资源命名、协作流程与导出说明。
├── .gitignore                                     # [NEW] Git 忽略规则；排除 Godot 导入缓存、临时文件与本地构建产物。
├── .gitattributes                                 # [NEW] Git LFS 配置；将 CG、立绘、音频等大文件纳入 LFS，降低仓库冲突与体积风险。
├── export_presets.cfg                             # [NEW] Windows 导出配置；为后续 `.exe` 打包预留稳定配置。
├── Patrick Star/po/modules/foundation/phase-1-brief.md
│                                                   # [NEW] PO 阶段说明；记录本轮范围、里程碑、验收标准与不做项。
├── Patrick Star/design/modules/foundation/game-design-brief.md
│                                                   # [NEW] 设计简案；沉淀角色线、校园区域、事件结构和 CG 使用规则。
├── Patrick Star/qa/modules/foundation/test-checklist.md
│                                                   # [NEW] QA 清单；覆盖探索、事件、好感度、存档、导出前冒烟验证。
├── scenes/main/main.tscn                          # [NEW] 主入口场景；负责启动游戏、加载全局 UI 和切入校园地图。
├── scenes/world/campus_map.tscn                   # [NEW] 校园主地图；放置 TileMap、玩家出生点、NPC 与交互点，承载首版主要游玩空间。
├── scenes/ui/hud.tscn                             # [NEW] 主 HUD；显示日期时段、地点、交互提示与简要关系反馈。
├── scenes/ui/dialogue_panel.tscn                  # [NEW] 对话面板；负责台词、角色名、头像与选项展示。
├── scenes/ui/cg_gallery.tscn                      # [NEW] CG 图鉴界面；展示已解锁插画与锁定占位，支撑收藏感。
├── scenes/ui/save_load_menu.tscn                  # [NEW] 存档菜单；提供存档槽位、覆盖确认与读取入口。
├── scripts/autoload/game_state.gd                 # [NEW] 全局状态管理；保存日期、时段、标记、章节与当前地点。
├── scripts/autoload/save_manager.gd               # [NEW] 存档管理；序列化与反序列化进度，处理多槽位和兼容字段。
├── scripts/player/player_controller.gd            # [NEW] 玩家控制；处理移动、朝向、交互输入与地图内基础反馈。
├── scripts/world/interaction_point.gd             # [NEW] 交互点脚本；统一挂载到 NPC/点位上，向事件系统上报触发信息。
├── scripts/systems/time_system.gd                 # [NEW] 时段系统；驱动上课后、放学后、夜晚等阶段切换。
├── scripts/systems/affection_system.gd            # [NEW] 好感度系统；统一管理角色关系值、阈值判定与事件解锁。
├── scripts/systems/event_system.gd                # [NEW] 事件系统；建立事件索引、校验条件、执行效果、驱动对话与 CG。
├── scripts/ui/dialogue_controller.gd              # [NEW] 对话控制器；承接事件脚本输出并更新对话 UI。
├── scripts/ui/cg_gallery_controller.gd            # [NEW] 图鉴控制器；读取解锁状态并按配置展示 CG。
├── data/characters/characters.json                # [NEW] 角色配置；定义角色基础资料、初始关系、立绘与事件入口。
├── data/events/events.json                        # [NEW] 事件配置；定义触发位置、条件、效果、对话 ID 与 CG 关联。
├── data/cg/cg_gallery.json                        # [NEW] 图鉴配置；定义 CG 顺序、缩略图、解锁条件与展示元数据。
├── assets/art/placeholder/                        # [NEW] 占位美术目录；首版先用临时素材跑通流程，后续逐步替换正式资源。
├── assets/cg/                                     # [NEW] 正式 CG 目录；只存放事件插画与其缩略图资源。
├── assets/portraits/                              # [NEW] 角色立绘目录；用于对话演出和状态变化。
├── assets/tilesets/                               # [NEW] 校园地图瓦片目录；支撑校园主地图搭建。
└── assets/audio/                                  # [NEW] 音频目录；放置 BGM、环境音与简短交互音效。
```

## Key Data Structures

- **角色配置**建议包含：`id`、`name`、`portrait`、`initial_affection`、`route_flags`
- **事件配置**建议包含：`id`、`map_id`、`point_id`、`time_slot`、`conditions`、`dialogue_id`、`affection_delta`、`set_flags`、`cg_id`
- **存档数据**建议包含：`current_day`、`time_slot`、`location`、`affection_map`、`unlocked_cg`、`story_flags`

## Agent Extensions

### Skill

- **patrick-star**
- Purpose: 统一收束需求、控制首版范围、对外输出稳定结论
- Expected outcome: 得到聚焦于“小而美”校园恋爱 RPG 的 MVP 边界、阶段目标和验收口径

- **po-main**
- Purpose: 组织 Phase 1 到 Phase 3 的里程碑、文档落点、角色分工与审批节奏
- Expected outcome: 形成可执行的开发顺序、协作规范与阶段性交付标准

- **game-product-analyst**
- Purpose: 对参考作品做合规化体验拆解，提炼“校园日常 + 地图探索 + 好感度”的共性循环
- Expected outcome: 输出首版功能优先级、体验 benchmark 与差异化建议，避免盲目堆功能

### SubAgent

- **code-explorer**
- Purpose: 初始化后跨文件检索场景、脚本、数据配置之间的引用关系与改动面
- Expected outcome: 在后续迭代和验收时快速定位依赖链，降低回归和漏改风险