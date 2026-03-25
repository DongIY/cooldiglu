# Campus Heartbeat — 多 Agent 协作章程

> 版本: v1.0 | 起草: Patrick Star (PO) | 日期: 2026-03-20

---

## 一、核心团队与职责

| 代号 | 角色 | 职责范围 |
|------|------|---------|
| **Patrick Star** | PO / 项目总监 | 需求收口、优先级排序、迭代节奏、交付验收、对外沟通 |
| **dd** | 策划 (Design) | 游戏设计文档、剧情大纲、数值设计、关卡/事件编排、交互原型 |
| **cc** | 开发 (Dev/Coder) | GDScript 实现、系统架构、场景搭建、性能优化 |
| **aa** | 美术 (Art) | 角色立绘、CG 插图、UI 主题、Tilemap 素材、视觉规范 |
| **qa** | 质保 (QA) | 测试用例、冒烟测试、回归验证、缺陷追踪 |
| **uu** | 用户测试 (UserTest) | 试玩反馈、可用性评估、体验打分、改进建议 |

### 外挂位（按需启用）
| 代号 | 角色 | 启用场景 |
|------|------|---------|
| **gpa** | 产品分析师 (game-product-analyst) | 竞品分析、市场调研、体验拆解 |

---

## 二、工作链路

```
用户
  ↓ 提需求
Patrick Star (PO)
  ↓ 复述需求 → 判断阶段 → 定义范围 → 指派任务
dd / cc / aa / qa / uu (并行或串行)
  ↓ 交付物
Patrick Star (PO)
  ↓ 验收 → 汇总 → 反馈
用户
```

**铁律**：所有任务入口和出口都经过 PO。团队成员之间可直接协作，但关键决策必须回 PO 确认。

---

## 三、三阶段推进模型

每个 Sprint 按三阶段推进：

### Phase 1: 设计与对齐
- dd 产出策划案 / 交互原型
- aa 产出视觉方向稿 / 资源规范
- PO 审核对齐，输出明确的 Scope（做什么 + 不做什么）

### Phase 2: 开发与生产
- cc 按策划案实现功能
- aa 产出正式美术资源
- dd 补充数据配置（events.json 等）

### Phase 3: 质保与修复
- qa 执行测试用例 + 冒烟测试
- uu 试玩反馈 + 体验评分
- cc 修复缺陷 + 性能调优
- PO 验收并合入 main

---

## 四、分支与提交规范

| 分支命名 | 用途 | 合入目标 |
|----------|------|---------|
| `main` | 稳定发布线 | — |
| `develop` | 开发集成线 | → main (Sprint 结束) |
| `feature/<module>` | 功能开发 | → develop |
| `content/<topic>` | 剧情/数据配置 | → develop |
| `art/<asset-type>` | 美术资源 | → develop |
| `fix/<issue>` | 缺陷修复 | → develop |

### 提交信息格式
```
<type>(<scope>): <description>

类型: feat / fix / content / art / docs / refactor / test
范围: dialogue / map / cg / save / event / ui / audio / ...
```

---

## 五、文件组织约定

```
Patrick Star/
├── po/                      # PO 文档
│   ├── COLLABORATION_CHARTER.md   ← 本文件
│   ├── ROADMAP.md                 ← 产品路线图
│   └── modules/                   ← 按模块的迭代记录
├── design/                  # 策划文档 (dd)
│   └── modules/
│       ├── dialogue/        # 对话系统策划
│       ├── events/          # 事件/剧情策划
│       ├── map/             # 地图策划
│       └── ...
└── qa/                      # 测试文档 (qa)
    └── modules/
        ├── smoke_test/      # 冒烟测试用例
        └── ...
```

---

## 六、沟通与交接协议

1. **任务单格式**：PO 向成员派工时，使用标准任务单：
   - 任务 ID / 标题
   - 所属 Sprint & Phase
   - 目标描述（用户故事或技术目标）
   - 验收标准（AC）
   - 依赖项
   - 截止时间

2. **交付物要求**：
   - cc: 代码 + 简要 CHANGELOG
   - dd: Markdown 策划案 + JSON 数据
   - aa: 资源文件 + 规格说明
   - qa: 测试用例 + 执行结果 + 缺陷列表
   - uu: 体验报告 + 评分 + 改进建议

3. **评审节点**：每个 Phase 结束时 PO 做一次评审，产出评审纪要。
