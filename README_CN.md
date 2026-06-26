# 🛡️ mu-skill-creator · AI Skill 工程化创建与审计工具

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v1.0.0-green.svg)](https://github.com/mupoet/mu-skill-creator)
[![Skill](https://img.shields.io/badge/type-Skill-purple.svg)](https://mupoet.github.io/mu-skill-creator/)

[English](./README.md) | 中文

<p align="center">
  <a href="https://mupoet.github.io/mu-skill-creator/"><strong>Landing Page</strong></a> ·
  <a href="https://github.com/mupoet/mu-skill-creator/issues"><strong>问题反馈</strong></a> ·
  <a href="mailto:muippt@agent.qq.com"><strong>联系我</strong></a>
</p>

> **不只是写一个 Skill 文件 —— 而是工程化地确保它不会失败。**

mu-skill-creator 是一个用于创建和审计 AI Agent Skill（驱动 Agent 行为的结构化指令文件）的工程化脚手架。它不是让你随便写一个 prompt 然后祈祷它能用，而是通过阶段门控、自动化审计和三层架构，系统性地预防三种导致 Skill 随时间退化的失效模式：**规则遗忘、规则冲突、规则膨胀**。项目源自 20 个真实事故中归纳的反模式，每一条防护规则都能追溯到具体的失败案例。

---

## ✨ 核心亮点

- 🏗️ **三层模型** — L1 / L2 / L3 分层加载，控制上下文预算，防止指令膨胀挤占有效指令空间。
- 🚧 **8 阶段门控流程** — 每个阶段都有明确的进入和退出条件，不能跳过，不能"看起来差不多就行"。
- 🔍 **23 项质量清单** — 覆盖格式、结构和内容，配合自动审计脚本捕捉人眼容易遗漏的问题。
- 🚫 **20 条反模式** — 每一条都追溯到真实事故，让你不只知道规则"是什么"，还知道"为什么"。
- 🧪 **Eval 测试** — 可选但推荐的评估框架，准确率阈值 ≥85%。
- 🔒 **安全优先** — 硬性规则禁止在 Skill 文件中泄露凭证、API Key 或敏感数据。
- ⚡ **停滞检测** — 量化信号（stale_count）检测迭代过程何时卡住，并自动升级处理。

---

## 📐 三层模型

三层模型通过按需加载信息来控制上下文窗口使用。这直接对抗**规则膨胀** —— 把所有内容塞进一个文件，导致 Agent 在超过一定长度后开始忽略指令的失效模式。

| 层级 | 内容 | 预算 | 加载时机 |
|------|------|------|----------|
| **L1** | 触发词 + 适用/不适用条件 | ~100 词 | 始终加载 |
| **L2** | 工作流、原则、检查清单（SKILL.md） | ≤ 300 行 | 激活时加载 |
| **L3** | 详细文档、Schema、示例（references/） | 不限 | 按需加载 |

**设计理念：** L1 宁可过度触发也不漏触发（漏触发 = Skill 等于不存在；误触发可以纠正）。L2 限制在 300 行以内 —— 远低于典型框架限制 —— 以留出余量。L3 每个文件一个主题，最大引用深度为一跳（A→B 可以；A→B→C 禁止，因为多跳引用会导致 token 膨胀和指令遗忘）。

---

## 🎯 8 阶段创建流程

每个阶段都有**进入条件**（开始前必须满足的条件）和**退出条件**（进入下一阶段必须满足的条件）。这直接对抗**规则遗忘** —— 小改动在没有验证的情况下溜过去的失效模式。

| 阶段 | 做什么 | 退出条件 |
|------|--------|----------|
| **1. 理解需求** | 收集 3+ 个真实的输入→输出示例；识别 Skill 类型和不适用场景 | ≥3 个具体 I/O 示例已记录 |
| **1.5 收集案例** | 收集 3+ 个黄金案例、5+ 个失败案例、≥1 个有效 vs 无效对比 | 案例库完整（或"工具包装型，已跳过"） |
| **2. 规划** | 选择意图模式和架构模式；起草文件树 | 文件树确认，架构已选定 |
| **3. 编写 L1** | 编写触发词 + 适用/不适用条件；应用"宁紧勿松"原则 | 描述 ≤1024 字符，包含"不适用"场景 |
| **4. 编写 L2** | 编写 SKILL.md，含编号阶段、进/出门控、确认门控、交付前检查清单 | `wc -l SKILL.md` ≤ 300 |
| **5. 编写 L3** | 创建 references/ 文件；每个文件一个主题；建立索引 | 所有引用文件存在，SKILL.md 有索引 |
| **6. 可验证性审计** | 审查每条指令 —— 必须可用 是/否 判断（❌"写高质量代码" → ✅"lint 通过且 0 错误"） | 零条主观指令残留 |
| **7. 触发词优化** | 扫描禁用词；确保双语 5+ 个触发变体；测试 10+10 触发/非触发 prompt | 准确率 ≥ 85%，无禁用词 |
| **8. 发布** | 安全扫描 → frontmatter 验证 → 打包 → 推送 | 已发布且在目标平台可搜索 |

---

## 🛡️ 反模式（AP-1 ~ AP-20）

每条反模式都追溯到真实事故。以下是 8 个代表性示例（完整 20 条见 [references/quality-gates.md](references/quality-gates.md)）：

| # | 反模式 | 修复方法 | 根因事故 |
|---|--------|----------|----------|
| AP-1 | SKILL.md 超过 250 行 | 拆分到 references/；以有效性为先 | 一个 418 行的 Skill —— Agent 直接忽略了后半部分 |
| AP-2 | 描述包含营销话术 | 描述 = 仅触发条件 | 描述中写"高效便捷" → 触发匹配率为零 |
| AP-3 | 阶段无编号或退出条件 | 添加编号 + 完成标准 | Sub-agent 跳过步骤；无法判断进度 |
| AP-5 | 无完成门控 | 添加验证步骤 | 审计跑完了但没人确认结果就交付了 |
| AP-7 | 无确认门控 | 破坏性操作前要求用户确认 | Agent 未等待确认就自动发布了 |
| AP-12 | 循环无终止条件 | 添加最大迭代次数 / 超时退出 | 串行 CLI 调用无限运行直到超时 |
| AP-17 | Shell 脚本无 shebang / `set -euo pipefail` | 添加 shebang + 安全标志 | 脚本静默失败；Agent 以为执行成功 |
| AP-19 | 规则只说 MUST/NEVER 没说 WHY | 附上 WHY 解释意图 | Agent 记住了禁令但在边界情况做出错误选择 |

> **失效模式映射：** 遗忘 → AP-3/5/8/17 · 冲突 → AP-4/14/16/18 · 膨胀 → AP-1/9/13/15/20 · 跨类 → AP-6/7/10/11/12/19

---

## ✅ 23 项质量清单

运行自动审计，然后手动验证脚本无法检查的项目：

```bash
bash scripts/skill-audit.sh <skill-name>
```

### 格式（9 项）

- IRON LAW 位于 frontmatter 之后（如需要），含领域特定约束 —— 无样板文
- 描述：单行，无 emoji，含触发词 + "不适用"场景，≤10 个触发词
- 简介：三段式格式，emoji ≠ 描述（如平台支持）
- 名称：小写 + 数字 + 连字符，与目录名匹配
- 行数 ≤ 300；超出按 AP-1 拆分（有效性优先）
- 所有阶段编号 + 进/出条件；无 AP-1~20 违规；指令可用 是/否 验证
- 内部 API → 确认认证方案 + 无硬编码凭证
- 破坏性操作 → 确认门控；流水线 → sub-agent 规格（≤30 行）
- 🚨 安全：无真实 API Key / AK / SK / Cookie；无人员信息；无受限系统

### 结构（10 项）

- 逻辑冲突：新规则与旧规则矛盾？编号与实际数量匹配？因果闭合：每个§1失效模式都被§3/§4/§7规则覆盖？
- 模板双源：同一内容在 SKILL.md 和 references/ 中重复？
- 僵尸文件：references/ 中不再被 SKILL.md 引用的文件？
- 断链：引用的文件实际存在？
- 路径孤儿：改名后的文件仍在旧路径被引用？
- 用户态数据：不应发布的个性化文件？
- 硬编码值：脚本中应参数化的值？
- 回归风险：改动可能破坏已有功能？
- 版本号：与改动范围匹配？
- references/ 索引：所有文件在列 + SKILL.md 有索引表

### 内容（7 项）

- 跨章节一致性：上下游表格与正文匹配？每个原则有对应 AP？每个 AP 引用根因事故和原则？
- 信息冗余：清单项目已被工作流正文覆盖？
- 交互一致性：多模式/分支流程不互相矛盾？
- 文案质量：错别字、歧义、矛盾？
- 退化链：每个外部依赖都有失败处理路径？
- 已知限制：存在 `## Known Limitations` 章节，诚实披露 Skill 做不到的事
- 停滞检测：含循环/迭代/定时的 Skill 有 stale_count 机制

---

## 🚀 快速开始

**第一步 — 安装 Skill**

将 Skill 目录复制到你的 AI Agent 框架的技能文件夹：

```bash
git clone https://github.com/mupoet/mu-skill-creator.git
cp -r mu-skill-creator ~/.skills/mu-skill-creator
```

**第二步 — 创建新 Skill**

告诉你的 AI Agent：

```
创建一个新 Skill，用于 [描述你的使用场景]
```

Agent 会自动走完 8 阶段门控流程 —— 收集需求、规划架构、编写 L1/L2/L3、运行可验证性审计、优化触发词。

**第三步 — 审计已有 Skill**

```bash
bash ~/.skills/mu-skill-creator/scripts/skill-audit.sh my-skill-name
```

脚本检查 IRON LAW 位置、描述格式、安全风险、行数和结构完整性。绿色 = 通过，黄色 = 警告，红色 = 必须修复。

---

## 💡 使用场景

**从零创建新 Skill** — 走完完整 8 阶段流程：需求收集 → 案例收集 → 架构规划 → L1/L2/L3 编写 → 可验证性审计 → Eval 测试 → 触发词优化 → 发布。

**优化已有 Skill** — 对你的 Skill 运行 23 项质量清单。审计脚本自动捕捉格式违规和安全风险；人工审查覆盖结构健康和内容质量。

**发布前质量审计** — 先用 `skill-audit.sh` 自动扫描，再走完整清单。脚本抓住人容易漏的（行数、禁用词、缺少 shebang）；清单抓住脚本抓不住的（逻辑冲突、回归风险、文案质量）。

**给膨胀的 Skill 瘦身** — 应用三层模型：将详细文档和 Schema 移到 `references/`，保持 SKILL.md 在 300 行以内，确保单跳引用。AP-1 和 AP-4 指导整个过程。

**调优触发词准确率** — 第 7 阶段提供系统方法：扫描禁用词，确保双语覆盖（5+ 个变体），用 10 个正向 + 10 个负向 prompt 测试，目标 ≥85% 准确率。

---

## 📊 与同类方案对比

### vs. 无防护栏（随意编写 Skill）

| 维度 | 无防护栏 | mu-skill-creator |
|------|----------|------------------|
| 失效检测 | 部署后（用户投诉） | 部署前（23 项清单 + 审计脚本） |
| 上下文膨胀 | 不受控增长直到 Agent 忽略指令 | 三层模型 + 300 行上限 + 单跳引用 |
| 规则一致性 | 人工审查，容易漂移 | 自动跨章节检查 + 因果闭合验证 |
| 知识传承 | 口耳相传 | 20 条文档化反模式 + 根因追溯 |
| 触发可靠性 | 试错法 | 系统性测试 + ≥85% 准确率阈值 |

### vs. 简单模板

| 维度 | 简单模板 | mu-skill-creator |
|------|----------|------------------|
| 流程执行 | 建议步骤，容易跳过 | 阶段门控 + 进/出条件 —— 不能跳 |
| 质量保证 | "看起来不错"式审批 | 23 项清单 + 自动 `skill-audit.sh` |
| 失效预防 | 通用最佳实践 | 20 条反模式，每条来自真实事故 |
| 可验证性 | 主观质量判断 | 每条指令必须可用 是/否 判断 |
| 停滞处理 | 无 | 量化 stale_count + 升级规则 |
| 安全 | 临时审查 | 硬性规则 + 自动扫描凭证和敏感数据 |

---

## 🔒 安全与隐私

mu-skill-creator 执行严格的安全边界：

- **Skill 文件中禁止凭证** — API Key、Access Key、Secret Key、Cookie 和 Token 不得出现在任何 Skill 文件中。审计脚本自动扫描。
- **禁止人员和组织数据** — 姓名、工号、角色定义、组织架构和薪酬信息禁止出现在所有 Skill 文件中。
- **用户态数据隔离** — 本地偏好、已安装列表、快照和推荐历史必须通过 `.skillignore` 排除，并在 SKILL.md 中声明为"首次使用时自动生成"。防止发布者的数据污染下游用户。
- **运行时读取模式** — Skill 通过 ID 或 URL 引用外部内容并在运行时读取，内容永远不直接嵌入 Skill 中。

---

## 📁 文件结构

```
mu-skill-creator/
├── SKILL.md                    # 主 Skill 文件（L2 — 核心工作流）
├── references/
│   └── quality-gates.md        # 质量门控参考（L3 — AP 详情、评估、触发词优化）
├── scripts/
│   └── skill-audit.sh          # 自动审计脚本（bash，检查格式/安全/结构）
├── evals/
│   └── evals.json              # 评估测试用例
└── index.html                  # Landing Page
```

---

## 关于作者

💡 清华大学出版社签约作家 / 2026当当影响力作家 / 某互联网大厂AI大模型业务HR砖家 / 一级人力资源管理师 / 二级心理咨询师 / 野生设计师。

📚 著有[《图解团队管理》](https://item.m.jd.com/product/14547345.html)，服务客户有字节、腾讯、百度、移动、SMG、BOE……

📧 [muippt@agent.qq.com](mailto:muippt@agent.qq.com) · 🐙 [@mupoet](https://github.com/mupoet)

---

## 🤝 贡献

欢迎贡献！无论是来自你自身经验的新反模式、审计脚本的改进，还是翻译 —— 所有贡献都能帮助 Skill 更加可靠。

1. Fork 本仓库
2. 创建功能分支（`git checkout -b feat/my-improvement`）
3. 修改后运行审计：`bash scripts/skill-audit.sh mu-skill-creator`
4. 提交清晰的 commit message（`git commit -m "feat: add AP-21 for ..."`)
5. 发起 Pull Request

请确保你的改动在提交前通过审计脚本。如果你添加了新的反模式，请附上触发它的根因事故 —— 每条规则都应可追溯到真实失败。

---

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

---

## Star History

如果这个项目对你有帮助，请给一个 ⭐！

<a href="https://star-history.com/#mupoet/mu-skill-creator&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date" />
 </picture>
</a>

---

> 一句话总结：不是"随手写个 prompt 文件"，是"用工程方法确保 AI Skill 不会随时间退化"。

---

Made with ❤️ by [木先生iPPT](https://github.com/mupoet)

[⬆ 回到顶部](#️-mu-skill-creator--ai-skill-工程化创建与审计工具)
