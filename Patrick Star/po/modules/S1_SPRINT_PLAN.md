# Sprint 1: 体验外壳 — 详细任务拆解

> Sprint Owner: Patrick Star (PO)
> 状态: 🟢 Active
> 日期: 2026-03-20

---

## 总体目标

> 让玩家启动游戏的 **第一分钟** 就感受到「这是一个完整产品」：
> 有标题画面可以进入、对话有立绘和打字机效果、UI 有统一风格。

---

## Phase 1: 设计与对齐

### 📋 TASK S1-P1-01 — 对话系统多页格式设计
- **指派**: dd (策划)
- **目标**: 设计 events.json 的多页对话扩展格式
- **交付物**: `Patrick Star/design/modules/dialogue/multi_page_spec.md`
- **验收标准**:
  - 向下兼容当前 `text` + `choices` 格式
  - 新增 `pages[]` 数组，每页有 `speaker`、`text`、可选 `portrait_variant`
  - 最后一页承载 `choices`
  - 附带 1 个示例事件 JSON

### 📋 TASK S1-P1-02 — 标题画面交互设计
- **指派**: dd (策划)
- **目标**: 定义标题画面的布局、按钮行为、进入游戏流程
- **交付物**: `Patrick Star/design/modules/title_screen/title_screen_spec.md`
- **验收标准**:
  - 定义布局（标题文字位置、按钮组、背景层次）
  - 新游戏 → 重置状态 → 进入主场景
  - 继续 → 读取最近存档 → 进入主场景（无存档时灰置）
  - 退出 → 确认对话 → 关闭游戏

### 📋 TASK S1-P1-03 — UI 配色与字体规范
- **指派**: aa (美术)
- **目标**: 产出校园恋爱主题的 UI 视觉规范
- **交付物**: `Patrick Star/design/modules/ui/ui_style_guide.md`
- **验收标准**:
  - 主色/辅色/强调色定义（Hex 值）
  - 字体推荐（中文+英文）及大小层级
  - 按钮样式（normal/hover/pressed/disabled 四态）
  - 对话框样式（背景色/透明度/圆角/边框）

---

## Phase 2: 开发与生产

### 🔧 TASK S1-P2-01 — 标题画面实现
- **指派**: cc (开发)
- **依赖**: S1-P1-02 (标题画面设计), S1-P2-07 (背景图)
- **目标**: 创建 title_screen.tscn + title_screen.gd
- **交付物**:
  - `scenes/ui/title_screen.tscn`
  - `scripts/ui/title_screen.gd`
  - 修改 `project.godot` 主场景为 title_screen
- **验收标准**:
  - 显示游戏标题 + 三个按钮
  - "新游戏" → 清空状态 → 切换到 main.tscn
  - "继续" → 加载存档 → 切换到 main.tscn
  - "退出" → get_tree().quit()
  - 无存档时 "继续" 按钮 disabled

### 🔧 TASK S1-P2-02 — 对话系统升级：立绘显示
- **指派**: cc (开发)
- **依赖**: S1-P2-06 (立绘资源)
- **目标**: 在 DialoguePanel 中增加角色立绘区域
- **交付物**:
  - 修改 `scenes/ui/dialogue_panel.tscn`（增加 TextureRect）
  - 修改 `scripts/ui/dialogue_controller.gd`（加载立绘逻辑）
- **验收标准**:
  - 对话时左侧显示说话者立绘
  - 无立绘的角色（旁白）不显示图片区域
  - 立绘切换有简单 fade 过渡

### 🔧 TASK S1-P2-03 — 对话系统升级：打字机效果
- **指派**: cc (开发)
- **依赖**: 无
- **目标**: 文字逐字显示
- **交付物**: 修改 `scripts/ui/dialogue_controller.gd`
- **验收标准**:
  - 文字按 `chars_per_second`（默认 30）逐字显示
  - 显示过程中点击/Enter → 立即显示全文
  - 全文显示后点击 → 进入下一页或显示选项
  - 速度可通过常量或后续设置调节

### 🔧 TASK S1-P2-04 — 对话系统升级：多页支持
- **指派**: cc (开发) + dd (数据)
- **依赖**: S1-P1-01 (多页格式设计)
- **目标**: EventSystem + DialogueController 支持多页对话
- **交付物**:
  - 修改 `scripts/systems/event_system.gd`（多页数据传递）
  - 修改 `scripts/ui/dialogue_controller.gd`（翻页状态机）
  - dd 更新 `data/events/events.json`（现有事件改为多页格式）
- **验收标准**:
  - 兼容旧单页格式（text+choices 仍可用）
  - 多页时逐页展示，每页可有不同 speaker
  - 最后一页展示选项按钮
  - 按 E/Enter/点击 翻页

### 🔧 TASK S1-P2-05 — UI 主题应用
- **指派**: cc (开发)
- **依赖**: S1-P1-03 (UI 规范)
- **目标**: 创建 Godot Theme 资源并应用到所有 UI
- **交付物**:
  - `assets/themes/campus_theme.tres`
  - 修改所有 `.tscn` UI 场景引用主题
- **验收标准**:
  - 按钮、面板、标签统一风格
  - 对话框有半透明深色背景
  - 不再使用 Godot 默认灰色样式

### 🎨 TASK S1-P2-06 — 角色占位立绘
- **指派**: aa (美术)
- **目标**: 为两位角色各制作 1 张站立立绘
- **交付物**:
  - `assets/portraits/char_lin_default.png` (替换 SVG)
  - `assets/portraits/char_yuki_default.png`
- **规格**: 512×1024px, PNG, 透明背景
- **风格**: 简约日系插画风（可先用 AI 生成占位，后续精修）

### 🎨 TASK S1-P2-07 — 标题背景图
- **指派**: aa (美术)
- **目标**: 标题画面用的校园背景
- **交付物**: `assets/art/title_bg.png`
- **规格**: 1280×720px, PNG/JPG
- **风格**: 黄昏校园全景，温暖色调

---

## Phase 3: 质保与验收

### 🧪 TASK S1-P3-01 — Sprint 1 冒烟测试
- **指派**: qa
- **测试范围**:
  - [ ] 标题画面：三个按钮功能正确
  - [ ] 新游戏流程：正常进入游戏
  - [ ] 继续游戏：有存档时正确恢复
  - [ ] 对话立绘：正确显示/隐藏
  - [ ] 打字机效果：正常播放/跳过
  - [ ] 多页对话：正常翻页，最后一页显示选项
  - [ ] 选择后效果正常（好感/flag/时间）
  - [ ] UI 主题一致性
  - [ ] F5/F9/Esc 快捷键仍正常
- **交付物**: `Patrick Star/qa/modules/S1_smoke_test.md`

### 🎮 TASK S1-P3-02 — Sprint 1 体验评估
- **指派**: uu
- **评估维度**:
  - 首次启动到开始游戏的流畅度（1-5分）
  - 对话阅读体验（1-5分）
  - 视觉一致性感受（1-5分）
  - 整体「产品完成感」（1-5分）
- **交付物**: `Patrick Star/qa/modules/S1_ux_review.md`

---

## 执行顺序 & 并行度

```
Week 1:
  [并行] dd: S1-P1-01 (多页格式) + S1-P1-02 (标题设计)
  [并行] aa: S1-P1-03 (UI规范) + S1-P2-06 (立绘) + S1-P2-07 (背景图)
  [并行] cc: S1-P2-03 (打字机效果, 无依赖)

Week 2:
  [串行] cc: S1-P2-04 (多页支持, 依赖 dd 的格式设计)
  [串行] cc: S1-P2-02 (立绘显示, 依赖 aa 的立绘)
  [串行] cc: S1-P2-01 (标题画面, 依赖 aa 的背景图)
  [并行] cc: S1-P2-05 (UI 主题, 依赖 aa 的规范)

Week 3:
  qa: S1-P3-01 (冒烟测试)
  uu: S1-P3-02 (体验评估)
  cc: 修复反馈问题
  PO: 验收 + 合入 main
```
