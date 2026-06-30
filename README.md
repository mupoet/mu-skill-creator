<p align="center">
  <img alt="mu-skill-creator" src="assets/default-banner.png" width="100%">
</p>

# 🦐 mu-skill-creator

> An AI agent skill that creates and audits other skills — with a 3-layer architecture model, 8-stage gated workflow, and 49-item 10-layer audit model that turns "it looks fine" into verifiable engineering.

**English** | [中文](README_CN.md) | [🌐 Landing Page](https://mupoet.github.io/mu-skill-creator/)

[![WeChat](https://img.shields.io/badge/muippt-07C160?logo=wechat&logoColor=white)](https://mp.weixin.qq.com/s/v1JSZvlN5fvbOOHvkvXEtA)
[![Xiaohongshu](https://img.shields.io/badge/muippt-FF2442?logo=xiaohongshu&logoColor=white)](https://xhslink.com/m/ESxtgUNMdl)
[![Book](https://img.shields.io/badge/Book-Visual%20Team%20Management-BBDDE5?logo=bookstack&logoColor=white)](https://item.m.jd.com/product/14547345.html)
[![License](https://img.shields.io/github/license/mupoet/mu-skill-creator)](LICENSE)
[![Version](https://img.shields.io/github/v/release/mupoet/mu-skill-creator)](https://github.com/mupoet/mu-skill-creator/releases)
[![Stars](https://img.shields.io/github/stars/mupoet/mu-skill-creator)](https://github.com/mupoet/mu-skill-creator/stargazers)

## 💡 Usage Examples

- 🆕 **Create a New Skill** — "I want to build an interview review skill" → Full 8-stage guided workflow from requirements to audit
- 🔧 **Optimize an Existing Skill** — "This skill loops forever" → Pinpoint AP-12, add termination conditions
- 🛡️ **Quality Audit** — "Check this skill for issues" → Run 49-item 10-layer checklist, red/yellow/green per item
- 📏 **Line Budget Enforcement** — "SKILL.md is too long" → Split using 3-layer model, only if no quality loss
- 🔍 **Trigger Word Tuning** — "Agent never activates my skill" → Optimize description + run ≥85% accuracy test
- 🧪 **Run Eval Tests** — With/without skill comparison to quantify actual effectiveness
- ⚠️ **Stall Detection** — Built-in stale_count mechanism to escape infinite iteration traps
- 📐 **Verify Testability** — Convert subjective "write quality code" into objective "lint passes with 0 errors"

## ✨ Core Highlights

### 🧠 Three Design Decisions

Skill quality degrades through three systemic failure modes. Every rule in the framework targets one of them:

| Failure Mode | Symptom | Countermeasure |
|---|---|---|
| Rule Forgetting | Small changes skip checks → quality erodes in the cracks | **Stage Gating** — Each stage has independent entry/exit criteria |
| Rule Conflict | Old and new rules contradict → Agent picks the wrong one | **Audit Script + Checklist** — Cross-section consistency via automated scan |
| Rule Bloat | Trying to govern everything → 300+ lines overflow → instructions ignored | **3-Layer Model** — L1/L2/L3 tiered loading |

### 📐 Three-Layer Architecture (L1 / L2 / L3)

| Layer | Content | Budget | Loading |
|---|---|---|---|
| L1 | Trigger words + use/skip conditions | ~100 words | Always |
| L2 | Workflow, principles, cheat sheets | ≤300 lines | On activation |
| L3 | Detailed docs, schemas, examples | Unlimited | On demand |

This architecture ensures minimal context consumption when idle, while providing full depth when activated. The 300-line budget for L2 is a deliberate constraint — if your workflow doesn't fit, it's a signal to externalize reference material to L3.

### 🚀 8-Stage Gated Workflow

Every skill passes through eight stages, each with explicit entry/exit criteria that prevent premature advancement:

| Stage | Name | Exit Gate |
|---|---|---|
| 1 | Requirements | ≥3 input/output examples documented |
| 1.5 | Case Studies | 3+ golden cases / 5+ failure cases |
| 2 | Planning | File tree + architecture pattern confirmed |
| 3 | Write L1 (description) | Trigger words + "not applicable" scope |
| 4 | Write L2 (SKILL.md) | ≤300 lines + checklist included |
| 5 | Write L3 (references/) | All references one-hop only |
| 6 | Verifiability Review | All instructions convertible to yes/no |
| 7 | Trigger Optimization | accuracy ≥85% |

### ✅ 49-Item 10-Layer Audit Model

Organized into 10 layers for full-spectrum quality coverage, with 26 items automatable via script:

| Layer | Audit Target | Items | Auto |
|---|---|---|---|
| L1 | Document Structure | 6 | 4 |
| L2 | Architecture Consistency | 5 | 2 |
| L3 | Code Quality | 8 | 6 |
| L4 | Cross-file Consistency | 3 | 0 |
| L5 | Doc ↔ Code Alignment | 2 | 2 |
| L6 | Dependency Integrity | 3 | 2 |
| L7 | File Hygiene | 6 | 5 |
| L8 | Security Compliance | 4 | 3 |
| L9 | Robustness & Degradation | 7 | 1 |
| L10 | Content Quality | 5 | 1 |

### 🛡️ 32 Anti-Patterns (AP-1 ~ AP-32)

Each pattern traces to a real incident and maps to a design principle — not "don't do X" memorization, but "why X crashes" experience:

| # | Anti-Pattern | Root Cause |
|---|---|---|
| 1 | >250 lines bloat | Agent ignores latter half of instructions |
| 2 | Description as marketing copy | Trigger becomes an ad, can't route-match |
| 3 | Stages without numbering/exit | Sub-agent can't track progress |
| 7 | No Confirmation Gate | Executes without waiting for approval |
| 9 | IRON LAW is boilerplate | Generic constraints waste line budget |
| 12 | Loop without termination | Serial CLI runs with no upper bound |
| 21 | Frontmatter contains real MIS | Public skill exposes creator identity |
| 23 | eval/exec on user input | Code injection risk |
| 32 | Missing .gitignore with scripts/ | Platform artifacts leak into repo |

### 🔍 Automated Audit Script

```bash
bash scripts/skill-audit.sh <skill-name>
```

Per-item scan, green/yellow/red output, 49 items across 10 layers checked one by one — "it looks fine" is no longer a delivery standard.

## 📌 Comparison

### mu-skill-creator vs. Manual Creation

| Dimension | mu-skill-creator | Manual Creation |
|---|---|---|
| Quality Gates | ✅ 49-item 10-layer automated checklist | ❌ Eyeballing only |
| Failure Mode Defense | ✅ 3 modes + 32 anti-patterns | ❌ Learn by crashing |
| Line Budget | ✅ 3-layer model + split guidance | ❌ Grows forever |
| Stage Management | ✅ Entry/exit criteria enforced | ❌ Write as you go |
| Audit Repeatability | ✅ Script + checklist | ❌ Varies by person |
| Degradation Chain | ✅ Every dependency has a fallback | ❌ Discover on failure |
| Known Limitations | ✅ Mandatory disclosure | ❌ Suffer in silence |

### mu-skill-creator vs. Simple Templates

| Dimension | mu-skill-creator | Simple Template |
|---|---|---|
| Design Decision Explanation | ✅ WHY + root cause incidents | ❌ Template only |
| Anti-Pattern Defense | ✅ 32 APs with fix examples | ❌ None |
| Stall Detection | ✅ Quantitative signals + structure change | ❌ None |
| Trigger Optimization | ✅ accuracy ≥85% testing | ❌ By feel |
| Extensibility | ✅ references/ on-demand loading | ❌ Single file |

## 🚀 Workflows

| Workflow | Scenario | Trigger |
|---|---|---|
| Full Creation | Build a new skill from zero | "create a skill", "new skill" |
| Quick Audit | Check an existing skill's quality | "audit this skill", "quality check" |
| Trigger Optimization | Improve trigger word accuracy | "optimize triggers", "trigger test" |
| Security Review | Pre-publish safety check | "security scan", "pre-publish check" |
| Eval Testing | Quantify skill effectiveness | "run eval", "test accuracy" |

## ⚙️ Technical Specs

| Item | Description |
|---|---|
| Runtime | Agent framework (native support, compatible with all deployment modes) |
| Audit Script | Bash (`skill-audit.sh`) |
| Core Output | SKILL.md + references/ + scripts/ + evals/ |
| Design Philosophy | 3-layer model + stage gating + audit script |
| Package Size | 19KB |

## 🛠️ Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/mupoet/mu-skill-creator.git

# 2. Run audit on any skill
bash scripts/skill-audit.sh <skill-name>

# 3. Tell your agent "create a new skill" to start the 8-stage workflow
```

## 🔒 Security & Privacy

- All processing happens locally — no data leaves your machine
- Audit script scans for credentials, API keys, and PII
- No telemetry, no tracking, no external data collection
- MIT License, open source friendly

## Star History

If this quality framework saved you from publishing a broken skill, consider giving it a ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date)](https://star-history.com/#mupoet/mu-skill-creator&Date)

> Because "it looks fine" is not a quality gate.

## 👤 About the Author

🎓 Signatory Author of Tsinghua University Press / 2026 Dangdang Influential Author / AI & Large Model Business HR Specialist at a Leading Tech Company / National Level-1 HR Manager / Level-2 Psychological Counselor / Self-taught Designer

📚 Author of [*Visual Team Management*](https://item.m.jd.com/product/14547345.html). Clients include ByteDance, Tencent, Baidu, China Mobile, SMG, BOE…

💡 [WeChat Official Account](https://mp.weixin.qq.com/s/v1JSZvlN5fvbOOHvkvXEtA) / [Xiaohongshu](https://xhslink.com/m/ESxtgUNMdl): muippt

## 📄 License & Acknowledgments

[MIT](LICENSE) © 2025 木老师 (Mr. Mu)

Built on insights from hundreds of real-world AI agent skill development iterations.

> Note: Much of this project was co-created with AI assistance. If you believe your work has been used without proper attribution, please open an issue.
