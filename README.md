# 🛡️ mu-skill-creator

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-v1.0.0-green.svg)](https://github.com/mupoet/mu-skill-creator)
[![Skill](https://img.shields.io/badge/type-Skill-purple.svg)](https://mupoet.github.io/mu-skill-creator/)

**Not just write a Skill file — engineer it not to fail.**

mu-skill-creator is an engineering scaffold for creating and auditing AI agent Skills (structured instruction files that drive agent behavior). Instead of writing free-form prompts and hoping they work, it applies stage gates, automated audits, and a three-layer architecture to systematically prevent the three failure modes that cause Skills to degrade over time: rule forgetting, rule conflict, and rule bloat. Born from 20 real-world incidents catalogued as anti-patterns, every guardrail in this project traces back to an actual failure.

## ✨ Highlights

- 🏗️ **Three-Layer Model** — L1 / L2 / L3 tiered loading keeps context budgets under control and prevents instruction bloat from crowding out effective directives.
- 🚧 **8-Stage Gated Workflow** — each stage has explicit entry and exit conditions; no skipping, no "looks good to me" handwaves.
- 🔍 **23-Item Quality Checklist** — covering format, structure, and content, with an automated audit script that catches what human eyes miss.
- 🚫 **20 Anti-Patterns** — each traced to a real incident, so you learn *why* a rule exists, not just that it does.
- 🧪 **Eval Testing** — optional but recommended evaluation framework with accuracy thresholds (≥85%).
- 🔒 **Security-First** — hard rules against leaking credentials, API keys, or sensitive data into Skill files.
- ⚡ **Stall Detection** — quantitative signals (stale_count) detect when iterative processes get stuck, with automatic escalation.

## 📐 Three-Layer Model

The three-layer model controls context window usage by loading information only when needed. This directly combats **rule bloat** — the failure mode where stuffing everything into one file causes agents to ignore instructions past a certain point.

| Layer | Content | Budget | When Loaded |
|-------|---------|--------|-------------|
| **L1** | Trigger words + use/skip conditions | ~100 words | Always |
| **L2** | Workflow, principles, checklists (SKILL.md) | ≤ 300 lines | On activation |
| **L3** | Detailed docs, schemas, examples (references/) | Unlimited | On demand |

**Design rationale:** L1 favors over-triggering over under-triggering (a missed trigger = the Skill doesn't exist; a false trigger is correctable). L2 is capped at 300 lines — well under typical framework limits — to leave headroom. L3 uses one file per topic with a maximum one-hop reference depth (A→B is fine; A→B→C is banned, because multi-hop references cause token bloat and instruction forgetting).

## 🎯 8-Stage Creation Workflow

Every stage has an **entry condition** (what must be true before starting) and an **exit condition** (what must be true before moving on). This combats **rule forgetting** — the failure mode where small changes slip through without verification.

| Stage | What Happens | Exit Condition |
|-------|-------------|----------------|
| **1. Understand Requirements** | Collect 3+ real input→output examples; identify Skill type and non-applicable scenarios | ≥3 concrete I/O examples documented |
| **1.5 Find Case Studies** | Gather 3+ golden cases, 5+ failure cases, ≥1 effective vs. ineffective comparison | Case inventory complete (or "tool-wrapper type, skipped") |
| **2. Plan** | Choose intent pattern and architecture pattern; draft file tree | File tree confirmed, architecture selected |
| **3. Write L1** | Write trigger words + use/skip conditions; apply Pushy Principle (prefer over-triggering) | Description ≤1024 chars, includes "not applicable" scenarios |
| **4. Write L2** | Write SKILL.md with numbered stages, entry/exit gates, Confirmation Gates, Pre-Delivery Checklist | `wc -l SKILL.md` ≤ 300 |
| **5. Write L3** | Create references/ files; one topic per file; build index | All referenced files exist, SKILL.md has index |
| **6. Verifiability Audit** | Review every instruction — must be yes/no judgeable (❌ "write quality code" → ✅ "lint passes with 0 errors") | Zero subjective instructions remain |
| **7. Trigger Word Optimization** | Scan for banned words; ensure 5+ trigger variants in both languages; test 10+10 trigger/non-trigger prompts | Accuracy ≥ 85%, no banned words |
| **8. Publish** | Security scan → frontmatter validation → package → push | Published and searchable on target platform |

## 🛡️ Anti-Patterns (AP-1 ~ AP-20)

Every anti-pattern is traced to a real incident. Here are 8 representative examples (full list of 20 in [references/quality-gates.md](references/quality-gates.md)):

| # | Anti-Pattern | Fix | Root Cause Incident |
|---|-------------|-----|---------------------|
| AP-1 | SKILL.md > 250 lines | Split to references/; prioritize effectiveness | A 418-line Skill — agent ignored the second half entirely |
| AP-2 | Description contains marketing copy | Description = trigger conditions only | "Efficient and convenient" in description → zero trigger matches |
| AP-3 | Stages without numbering or exit conditions | Add numbering + completion criteria | Sub-agent skipped steps; couldn't determine progress |
| AP-5 | No completion gate | Add verification step | Audit ran but nobody confirmed results before delivery |
| AP-7 | No Confirmation Gate | Require user confirmation before destructive actions | Agent auto-published without waiting for approval |
| AP-12 | Loop with no termination condition | Add max iterations / timeout exit | Serial CLI calls ran indefinitely until timeout |
| AP-17 | Shell script without shebang / `set -euo pipefail` | Add shebang + safety flags | Script failed silently; agent assumed success |
| AP-19 | Rules say MUST/NEVER without WHY | Attach WHY explaining intent | Agent memorized prohibition but chose wrong action at edge cases |

> **Failure mode mapping:** Forgetting → AP-3/5/8/17 · Conflict → AP-4/14/16/18 · Bloat → AP-1/9/13/15/20 · Cross-cutting → AP-6/7/10/11/12/19

## ✅ 23-Item Quality Checklist

Run the automated audit, then manually verify the items the script can't catch:

```bash
bash scripts/skill-audit.sh <skill-name>
```

### Format (9 items)

- IRON LAW present after frontmatter (if needed) with domain-specific constraints — no boilerplate
- Description: single line, no emoji, includes trigger words + "not applicable" scenarios, ≤10 triggers
- Intro: three-section format with emoji ≠ description (if platform supports it)
- Name: lowercase + digits + hyphens, matches directory name
- Line count ≤ 300; excess split per AP-1 (effectiveness first)
- All stages numbered with entry/exit conditions; no AP-1~20 violations; instructions are yes/no verifiable
- Internal API → auth scheme confirmed + no hardcoded credentials
- Destructive actions → Confirmation Gate; pipelines → sub-agent spec (≤30 lines)
- 🚨 Security: no real API keys / AK / SK / cookies; no personnel info; no restricted systems

### Structure (10 items)

- Logic conflicts: new rules contradict old ones? Numbering matches actual count? Causal closure: every §1 failure mode covered by §3/§4/§7 rules?
- Template dual-source: same content duplicated in SKILL.md and references/?
- Zombie files: files in references/ no longer referenced by SKILL.md?
- Broken links: referenced files actually exist?
- Path orphans: renamed files still referenced in old paths?
- User-state data: personalized files that shouldn't be published?
- Hardcoded values: scripts contain values that should be parameterized?
- Regression: changes might break existing functionality?
- Version number: matches scope of changes?
- references/ index: all files present + SKILL.md has index table

### Content (7 items)

- Cross-section consistency: upstream/downstream tables match prose? Every principle has a corresponding AP? Every AP cites root-cause incident and principle?
- Information redundancy: checklist items already covered by workflow prose?
- Interaction consistency: multi-mode/branch flows don't contradict each other?
- Copy quality: typos, ambiguity, contradictions?
- Degradation chain: every external dependency has a failure-handling path?
- Known limitations: `## Known Limitations` section present, honestly disclosing what the Skill can't do
- Stall detection: Skills with loops/iterations/cron have stale_count mechanism

## 🚀 Quick Start

**Step 1 — Install the Skill**

Copy the Skill directory into your AI agent framework's skill folder:

```bash
git clone https://github.com/mupoet/mu-skill-creator.git
cp -r mu-skill-creator ~/.skills/mu-skill-creator
```

**Step 2 — Create a new Skill**

Tell your AI agent:

```
Create a new Skill for [describe your use case]
```

The agent will follow the 8-stage gated workflow automatically — collecting requirements, planning architecture, writing L1/L2/L3, running verifiability audits, and optimizing trigger words.

**Step 3 — Audit an existing Skill**

```bash
bash ~/.skills/mu-skill-creator/scripts/skill-audit.sh my-skill-name
```

The script checks IRON LAW placement, description format, security risks, line count, and structural integrity. Green = pass, yellow = warning, red = must fix.

## 💡 Use Cases

**Create a new Skill from scratch** — Walk through the full 8-stage workflow: requirements gathering → case study collection → architecture planning → L1/L2/L3 writing → verifiability audit → eval testing → trigger optimization → publishing.

**Optimize an existing Skill** — Run the 23-item quality checklist against your Skill. The audit script catches format violations and security risks automatically; manual review covers structural health and content quality.

**Quality audit before release** — Use `skill-audit.sh` for automated scanning, then walk through the full checklist. The script catches what humans miss (line counts, banned words, missing shebang); the checklist catches what scripts can't (logic conflicts, regression risk, copy quality).

**Slim down a bloated Skill** — Apply the Three-Layer Model: move detailed docs and schemas to `references/`, keep SKILL.md under 300 lines, and ensure single-hop references only. AP-1 and AP-4 guide the process.

**Tune trigger words for accuracy** — Stage 7 provides a systematic approach: scan for banned words, ensure bilingual coverage (5+ variants), and test with 10 positive + 10 negative prompts targeting ≥85% accuracy.

## 📊 Comparison

### vs. No Guardrails (ad-hoc Skill writing)

| Dimension | No Guardrails | mu-skill-creator |
|-----------|--------------|------------------|
| Failure detection | After deployment (user reports) | Before deployment (23-item checklist + audit script) |
| Context bloat | Unchecked growth until agent ignores instructions | Three-layer model with 300-line cap and single-hop references |
| Rule consistency | Manual review, prone to drift | Automated cross-section checks + causal closure verification |
| Knowledge transfer | Tribal knowledge | 20 documented anti-patterns with root-cause tracing |
| Trigger reliability | Trial and error | Systematic testing with ≥85% accuracy threshold |

### vs. Simple Templates

| Dimension | Simple Template | mu-skill-creator |
|-----------|----------------|------------------|
| Workflow enforcement | Suggested steps, easily skipped | Stage gates with entry/exit conditions — can't skip |
| Quality assurance | "Looks good" approval | 23-item checklist + automated `skill-audit.sh` |
| Failure prevention | Generic best practices | 20 anti-patterns, each from a real incident |
| Verifiability | Subjective quality judgment | Every instruction must be yes/no judgeable |
| Stall handling | None | Quantitative stale_count with escalation rules |
| Security | Ad-hoc review | Hard rules + automated scanning for credentials and sensitive data |

## 🔒 Security & Privacy

mu-skill-creator enforces strict security boundaries:

- **No credentials in Skill files** — API keys, access keys, secret keys, cookies, and tokens must never appear in any Skill file. The audit script scans for these automatically.
- **No personnel or organizational data** — names, IDs, role definitions, org charts, and salary information are prohibited from all Skill files.
- **User-state data isolation** — local preferences, installed lists, snapshots, and recommendation history must be excluded via `.skillignore` and declared as "auto-generated on first use" in SKILL.md. This prevents a publisher's data from polluting downstream users.
- **Runtime-read pattern** — Skills reference external content by ID or URL and read it at runtime. Content is never embedded directly in the Skill.

## 📁 File Structure

```
mu-skill-creator/
├── SKILL.md                    # Main Skill file (L2 — the core workflow)
├── references/
│   └── quality-gates.md        # Quality gates reference (L3 — AP details, eval, trigger optimization)
├── scripts/
│   └── skill-audit.sh          # Automated audit script (bash, checks format/security/structure)
├── evals/
│   └── evals.json              # Evaluation test cases
└── index.html                  # Landing page
```

## 🤝 Contributing

Contributions are welcome! Whether it's a new anti-pattern from your own experience, an improvement to the audit script, or a translation — all contributions help make Skills more reliable.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-improvement`)
3. Make your changes and run the audit: `bash scripts/skill-audit.sh mu-skill-creator`
4. Commit with a clear message (`git commit -m "feat: add AP-21 for ..."`)
5. Open a Pull Request

Please ensure your changes pass the audit script before submitting. If you're adding a new anti-pattern, include the root-cause incident that motivated it — every rule should be traceable to a real failure.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">
  <a href="https://mupoet.github.io/mu-skill-creator/">📖 Landing Page</a> ·
  <a href="https://github.com/mupoet/mu-skill-creator">💻 GitHub</a> ·
  <a href="https://github.com/mupoet/mu-skill-creator/issues">🐛 Issues</a>
</p>
