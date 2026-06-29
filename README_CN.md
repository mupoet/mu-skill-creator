<p align="center">
  <img alt="mu-skill-creator" src="assets/banner.svg" width="100%">
</p>

# 🦐 mu-skill-creator

> 一个 Skill 搞定 Skill 从创作到质量门控的全流程：**设计决策** · **阶段门控** · **23项审计清单** · **反模式防御**

[English](README.md) | **中文** | [🌐 在线主页](https://mupoet.github.io/mu-skill-creator/)

[![License](https://img.shields.io/github/license/mupoet/mu-skill-creator)](LICENSE)
[![Stars](https://img.shields.io/github/stars/mupoet/mu-skill-creator)](https://github.com/mupoet/mu-skill-creator/stargazers)
[![Version](https://img.shields.io/github/v/release/mupoet/mu-skill-creator)](https://github.com/mupoet/mu-skill-creator/releases)

## 💡 使用场景示例

- 🆕 **新建 Skill** — "我要做一个面评写作的 Skill" → 完整8阶段引导，从需求到审计
- 🔧 **优化现有 Skill** — "这个 Skill 总是循环不停" → 定位AP-12，加终止条件
- 🛡️ **质量审计** — "帮我检查这个 Skill 有没有问题" → 跑23项清单，逐项红黄绿
- 📏 **行数瘦身** — "SKILL.md 太长了" → 按三层模型拆分，效果不减才可拆
- 🔍 **触发词调优** — "Agent 总是不触发我的 Skill" → description优化+accuracy测试
- 🧪 **运行 Eval 测试** — 有/无 Skill 对比，量化实际效果
- ⚠️ **停滞循环检测** — 内置 stale_count 机制，逃出无限迭代陷阱
- 📐 **验证指令可测试性** — 将主观的"写高质量代码"转化为客观的"lint 通过无 error"

## ✨ 核心亮点

### 🧠 三大设计决策

Skill 质量劣化有三个系统性失效模式，所有规则都针对它们：

| 失效模式 | 症状 | 对抗决策 |
|---|---|---|
| 规则遗忘 | 小改动不检查→质量在缝隙中劣化 | **阶段门控** — 每个阶段有独立入口/出口条件 |
| 规则冲突 | 新旧规则矛盾→Agent执行选错 | **审计脚本+清单** — 跨章节一致性靠脚本校验 |
| 规则膨胀 | 什么都想管→300行溢出→指令被忽略 | **三层模型** — L1/L2/L3分级加载 |

### 📐 三层模型架构

| 层级 | 内容 | 预算 | 加载时机 |
|---|---|---|---|
| L1 | 触发词 + 使用/跳过条件 | ~100词 | 始终 |
| L2 | 工作流、原则、速查表 | ≤300行 | 激活时 |
| L3 | 详细文档、schema、示例 | 不限 | 按需read |

L1 是唯一触发机制，倾向"宁多触发别漏"——漏触发意味着 Skill 等于不存在，误触发可以纠正。L2 严守 300 行预算（官方建议 500，保守取 300 留余量），引用仅允许一级跳转。L3 按主题拆分，超 100 行加索引。

### 🚀 八阶段门控工作流

每个阶段有独立入口/出口条件，未满足不可跳过——门控是结构约束，不是"建议"：

| 阶段 | 内容 | 出口条件 |
|---|---|---|
| 1 | 理解需求 | 输入输出示例≥3条 |
| 1.5 | 找实践案例 | 黄金案例3+/失败案例5+ |
| 2 | 规划架构 | 文件树+架构模式确定 |
| 3 | 写L1(description) | 触发词+不适用场景 |
| 4 | 写L2(SKILL.md) | ≤300行+Checklist |
| 5 | 写L3(references/) | 引用仅一跳 |
| 6 | 可验证性审查 | 全部yes/no判断 |
| 7 | 触发词优化 | accuracy≥85% |

### ✅ 23项质量审计清单

三大类覆盖从格式到内容的完整质量维度：

**格式规范（9项）**：IRON LAW 位置与内容 · description 格式与触发词 · 命名规范 · 行数预算 · 阶段编号与门控 · SSO 方案 · Confirmation Gate · 安全扫描 · 无真实凭据

**结构健康（10项）**：逻辑冲突 · 模板双源检测 · 僵尸文件 · 断链引用 · 路径同步 · 用户态数据隔离 · 硬编码检测 · 功能退化防护 · 版本号匹配 · 索引完整性

**内容质量（7项）**：跨章节一致性 · 信息冗余消除 · 交互一致性 · 文案质量 · 降级链完整性 · 已知局限披露 · 停滞检测机制

### 🛡️ 20条反模式（AP-1~AP-20）

每条标注根因事故和对应设计原则，不是"禁止X"的死记令，而是"为什么X会翻车"的经验提炼：

| # | 反模式 | 根因 |
|---|---|---|
| 1 | >250行膨胀 | Agent忽略后半段指令 |
| 2 | description写宣传语 | 触发器变广告，无法路由匹配 |
| 3 | 阶段无编号/出口 | 子Agent跳步无法判进度 |
| 7 | 无Confirmation Gate | 未等确认自作主张执行 |
| 9 | IRON LAW是套话 | 通用约束占行数不激活 |
| 12 | 循环无终止条件 | 串行CLI无上限超时 |
| 14 | 冗余重复提示 | 同一规则多处写导致冲突 |
| 19 | 规则只有MUST没WHY | 遇边界情况死记禁止令选错 |

### 🔍 自动化审计脚本

```bash
bash scripts/skill-audit.sh <skill-name>
```

逐项扫描、绿/黄/红三色输出、23项逐条打勾——目测"没问题"不再是交付标准。

## 📌 与同类工具对比

### mu-skill-creator vs 无规范手写

| 维度 | mu-skill-creator | 无规范手写 |
|---|---|---|
| 质量门控 | ✅ 23项自动化清单 | ❌ 全靠目测 |
| 失效模式防御 | ✅ 3大模式+20条AP | ❌ 踩坑才知道 |
| 行数控制 | ✅ 三层模型+拆分指导 | ❌ 越写越长 |
| 阶段管理 | ✅ 入口/出口条件 | ❌ 想到哪写到哪 |
| 审计可重复 | ✅ 脚本+清单 | ❌ 因人而异 |
| 降级链 | ✅ 每个依赖有兜底 | ❌ 出错才发现 |
| 已知局限披露 | ✅ 强制声明 | ❌ 默默承受 |

### mu-skill-creator vs 简单模板

| 维度 | mu-skill-creator | 简单模板 |
|---|---|---|
| 设计决策解释 | ✅ WHY+根因事故 | ❌ 只有模板 |
| 反模式防御 | ✅ 20条AP+修复示例 | ❌ 无 |
| 停滞检测 | ✅ 量化信号+换结构 | ❌ 无 |
| 触发词优化 | ✅ accuracy≥85%测试 | ❌ 凭感觉 |
| 可扩展性 | ✅ references按需加载 | ❌ 单文件 |

## 🚀 工作流

| 工作流 | 场景 | 触发方式 |
|---|---|---|
| 完整创建 | 从零开始构建新Skill | "创建skill"、"新建skill" |
| 快速审计 | 检查现有Skill质量 | "审计skill"、"质量检查" |
| 触发词优化 | 提升触发词准确率 | "优化触发词"、"触发测试" |
| 安全审查 | 发布前安全检查 | "安全扫描"、"发布前检查" |
| Eval测试 | 量化Skill有效性 | "运行eval"、"测试准确率" |

## ⚙️ 技术规格

| 项目 | 说明 |
|---|---|
| 运行环境 | OpenClaw 框架（原生支持，兼容所有部署方式） |
| 审计脚本 | Bash (skill-audit.sh) |
| 核心产出 | SKILL.md + references/ + scripts/ + evals/ |
| 设计哲学 | 三层模型 + 阶段门控 + 审计脚本 |
| 包大小 | 19KB |

## 🛠️ 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/mupoet/mu-skill-creator.git

# 2. 对任意 Skill 运行审计
bash scripts/skill-audit.sh <skill-name>

# 3. 对 Agent 说"帮我创建一个新 Skill"，即可触发8阶段创作流程
```

## 🔒 安全与隐私

- 纯本地运行，无网络请求
- 审计脚本扫描凭据/密钥/敏感信息
- 无遥测、无数据采集
- MIT License 开源友好

## Star 趋势

如果这个质量框架帮你避免了发布一个有问题的 Skill，请考虑给一个 ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date)](https://star-history.com/#mupoet/mu-skill-creator&Date)

> 因为"看起来没问题"不是质量门控。

### 👤 作者简介

🎓 清华大学出版社签约作家 / 2026当当影响力作家 / 某互联网大厂 AI 大模型业务 HR 砖家 / 一级人力资源管理师 / 二级心理咨询师 / 野生设计师

📚 著有[《图解团队管理》](https://item.m.jd.com/product/14547345.html)，服务客户有字节跳动、腾讯、百度、中国移动、SMG、BOE…

💡 [微信公众号](https://mp.weixin.qq.com/s/v1JSZvlN5fvbOOHvkvXEtA) / [小红书](https://xhslink.com/m/ESxtgUNMdl)：muippt

### 📄 许可证与致谢

[MIT](LICENSE) © 2025 木老师 (Mr. Mu)

基于数百次真实 AI Agent Skill 开发迭代的经验沉淀。感谢 OpenClaw 社区对这些质量模式的实战验证。

> 说明：本项目大部分内容由 AI 辅助完成。如您认为您的作品被使用但未获得适当署名，请提交 issue。
