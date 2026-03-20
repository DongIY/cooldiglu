# Campus Heartbeat

一个基于 **Godot 4.x** 的 2D 校园恋爱日常 RPG 原型项目。
首版目标是做出 **单校园区域 + 地图探索 + 好感度成长 + 剧情事件 + CG 解锁 + 存档读档** 的完整可玩闭环。

## 项目定位

- 题材：校园恋爱日常
- 玩法：地图探索、NPC互动、时段推进、关系成长、事件解锁
- 目标平台：Windows Desktop
- 引擎：Godot 4.x
- 语言：GDScript

## 首版 MVP 范围

- 1 张校园主地图（教学楼前庭 + 操场入口 + 天台入口等互动点）
- 2 名核心可互动角色
- 3 个时段（早晨 / 放学后 / 夜晚）
- 1 条完整角色线 + 1 条支线事件
- 1 个基础 CG 图鉴界面
- 1 套 JSON 存档读档方案

## 当前仓库结构

```text
scenes/         场景文件
scripts/        GDScript 逻辑
assets/         美术、音频、地图资源
data/           角色、事件、图鉴等 JSON 数据
Patrick Star/   PO / 设计 / QA 过程文档
```

## 运行方式

1. 使用 Godot 4.x 打开项目根目录。
2. 主场景为 `scenes/main/main.tscn`。
3. 首次运行会自动加载演示数据。

## 基础操作

- `WASD / 方向键`：移动
- `E / Enter / Space`：交互 / 确认
- `Tab`：打开 CG 图鉴
- `F5`：快速存档
- `F9`：快速读档

## 协作约定

- 剧情、角色、事件配置优先写入 `data/` 下的 JSON。
- 场景骨架与系统逻辑分离，避免把剧情硬编码进场景树。
- 大资源（CG、立绘、音频）走 **Git LFS**。
- 分支建议：
  - `main`：稳定主线
  - `feature/<module>`：功能开发
  - `content/<topic>`：剧情与配置补充

## 资源命名建议

- 角色：`char_<id>_<variant>`
- CG：`cg_<route>_<index>`
- 事件：`evt_<map>_<point>_<step>`
- 场景：`<module>_<purpose>.tscn`

## 近期里程碑

- Phase 1：完成工程骨架、文档与演示数据
- Phase 2：跑通探索 / 时段 / 对话 / 好感度 / CG / 存档闭环
- Phase 3：冒烟测试、引用校验、Windows 导出配置验证
