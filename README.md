# mu-skill-creator

An AI agent skill that creates and audits other skills — with a 3-layer architecture model, 8-stage gated workflow, and 23-item quality checklist that turns "it looks fine" into verifiable engineering.

## Usage Examples

- 🏗️ **Create a New Skill from Scratch** — Guided 8-stage workflow from requirements gathering to marketplace publishing
- 🔍 **Audit an Existing Skill** — Run the 23-item checklist to catch anti-patterns, structural issues, and security risks
- 📏 **Enforce the 300-Line Budget** — Automatically detect bloated SKILL.md files and suggest L3 reference splits
- 🎯 **Optimize Trigger Words** — Test 10+10 should/shouldn't trigger scenarios with ≥85% accuracy target
- 🛡️ **Security Scan Before Publish** — Detect hardcoded credentials, restricted system URLs, and PII leaks
- 🧪 **Run Eval Tests** — With/without skill comparison to quantify actual effectiveness
- ⚠️ **Detect Stale Loops** — Built-in stale_count mechanism to escape infinite iteration traps
- 📐 **Verify Instructions are Testable** — Convert subjective "write quality code" into objective "lint passes with 0 errors"

## Core Highlights

### Three-Layer Architecture (L1 / L2 / L3)

The skill system uses a three-layer loading model that balances always-on responsiveness with on-demand depth:

| Layer | Purpose | Size Constraint | Loading Strategy |
|-------|---------|----------------|------------------|
| **L1** — Trigger Layer | Trigger words, one-line description, activation rules | ~100 words | Always loaded in context |
| **L2** — Workflow Layer | Complete execution logic, decision trees, output templates | ≤300 lines | Loaded on skill activation |
| **L3** — Reference Layer | Deep knowledge bases, examples, lookup tables | Unlimited | Loaded on demand via explicit read |

This architecture ensures minimal context consumption when skills are idle, while providing full depth when activated. The 300-line budget for L2 is a deliberate constraint — if your workflow doesn't fit, it's a signal to externalize reference material to L3.

### 8-Stage Gated Workflow

Every skill passes through eight stages, each with explicit entry/exit criteria that prevent premature advancement:

| Stage | Name | Entry Gate | Exit Gate |
|-------|------|-----------|-----------|
| 1 | Requirements | User intent identified | Problem statement + success criteria documented |
| 2 | Case Studies | Requirements approved | 3+ real-world scenarios analyzed |
| 3 | Planning | Cases validated | Architecture decision (layers, tools, dependencies) |
| 4 | L1 + L2 Draft | Plan approved | SKILL.md written within budget |
| 5 | L3 References | L2 complete | Supporting materials externalized |
| 6 | Verifiability | All layers drafted | Every instruction converted to testable assertion |
| 7 | Eval & Trigger Optimization | Verifiable draft ready | 10+10 trigger test passes ≥85% accuracy |
| 8 | Publish | All gates passed | Marketplace listing + security scan clean |

The gating mechanism prevents the common failure mode of "it seemed done" — each stage must produce concrete artifacts before proceeding.

### 23-Item Quality Checklist

The audit checklist is organized into three categories:

**Format Standards (9 items)**

1. SKILL.md exists at expected path
2. L2 body ≤300 lines (conservative) / ≤500 lines (official max)
3. Trigger words section present with ≥5 positive triggers
4. "Not applicable" section explicitly defines boundaries
5. One-line description ≤30 words
6. No raw placeholder variables (`{{...}}`) remain
7. Markdown renders without errors
8. File encoding is UTF-8
9. No trailing whitespace or mixed line endings

**Structural Health (10 items)**

10. L1/L2/L3 separation is clean (no L3 content in L2)
11. Decision tree has no dead-end branches
12. All tool/CLI references are valid and accessible
13. Error handling covers top-3 failure modes
14. Stale detection mechanism present for iterative workflows
15. Output format explicitly specified (not "write something good")
16. Dependencies declared (other skills, tools, APIs)
17. No circular skill references
18. State externalization for multi-turn workflows
19. Execution and evaluation are separated (don't grade your own work)

**Content Quality (7 items)**

20. Every instruction is testable (no subjective adjectives without metrics)
21. Anti-pattern scan passes (0 hits from AP-1 to AP-20)
22. Security scan clean (no credentials, PII, or restricted URLs)
23. Trigger word test: 10 should-trigger + 10 shouldn't-trigger scenarios

### 9 Design Principles

The framework is built on 4 positive principles and 5 defensive principles:

**Positive Principles:**

1. **State Externalization** — Multi-turn workflows must persist state outside the conversation context, enabling recovery from interruptions
2. **Execution/Evaluation Separation** — The agent that does the work should not be the sole judge of quality; build in independent verification steps
3. **Direction Diversity** — Offer multiple valid paths rather than a single rigid sequence; real problems rarely have one correct approach
4. **Verifiable Output** — Every deliverable must have an objective "done" criterion that doesn't require human judgment to evaluate

**Defensive Principles:**

5. **Rules Trace to Incidents** — Every constraint in the checklist exists because someone shipped a broken skill without it; no rule is theoretical
6. **Structural Isolation** — Failures in one layer/stage must not cascade; L3 being unreadable should not crash L2 execution
7. **Assume Failure** — Design for the case where tools are unavailable, APIs timeout, or the user provides incomplete information
8. **Quantitative Stall Detection** — Use `stale_count` mechanisms to detect when iteration isn't producing progress; escalate after threshold
9. **Honest Limitations** — Explicitly declare what the skill cannot do; overpromising is an anti-pattern (AP-17)

### 20 Anti-Patterns

Common failure modes detected during audit:

| ID | Anti-Pattern | Risk | Fix |
|----|-------------|------|-----|
| AP-1 | God Skill | L2 tries to do everything, exceeds budget | Split into focused skills with clear boundaries |
| AP-2 | Trigger Collision | Overlapping triggers with other skills | Run 10+10 test, add disambiguation rules |
| AP-3 | Subjective Gate | "Write high-quality output" with no metric | Replace with testable criterion |
| AP-4 | Infinite Loop | No stale detection in iterative workflow | Add stale_count with max rounds |
| AP-5 | Context Bomb | L2 loads full L3 content unconditionally | Lazy-load L3 only when needed |
| AP-6 | Phantom Dependency | References tools/skills that don't exist | Validate all dependencies at audit time |
| AP-7 | Silent Failure | Errors swallowed without user notification | Explicit error handling with recovery path |
| AP-8 | Self-Grading | Skill evaluates its own output quality | Separate execution from evaluation |
| AP-9 | Hardcoded Secrets | API keys or credentials in SKILL.md | Security scan + environment variable pattern |
| AP-10 | PII Leakage | Personal data in examples or templates | Anonymize all sample data |
| AP-11 | Stale Reference | L3 points to URLs/files that no longer exist | Periodic link validation |
| AP-12 | Trigger Greed | Overly broad triggers that steal activations | Narrow triggers + explicit "not applicable" |
| AP-13 | Missing Boundary | No "not applicable" section defined | Always declare what you don't do |
| AP-14 | Template Bloat | Output templates exceed reasonable size | Externalize to L3, keep L2 logic only |
| AP-15 | Rigid Sequence | Forces linear execution when parallel is valid | Allow stage skipping with justification |
| AP-16 | No Recovery | Single failure point kills entire workflow | Checkpoint + resume mechanism |
| AP-17 | Overpromise | Claims capabilities beyond actual reach | Honest limitations section required |
| AP-18 | Version Drift | SKILL.md references outdated tool versions | Pin versions or use "latest" with validation |
| AP-19 | Monologue Mode | Produces output without checking user intent | Add confirmation checkpoints |
| AP-20 | Cargo Cult | Copies patterns without understanding why | Every rule must trace to a real incident |

## Comparison

| Dimension | Manual Creation | Generic AI Chat | mu-skill-creator |
|-----------|----------------|-----------------|------------------|
| Quality Consistency | Depends on author | Varies per session | 23-item checklist enforced |
| Trigger Word Testing | Rarely done | Not supported | 10+10 test with ≥85% accuracy |
| Anti-Pattern Detection | Manual review | Not aware of patterns | 20 AP auto-scan |
| Line Budget Control | Self-discipline | No awareness | ≤300 lines enforced |
| Security Scanning | Ad-hoc | Not included | Automated sensitive URL/credential scan |
| Stall Detection | Human judgment | No mechanism | stale_count with auto-escalation |
| Eval Framework | None | None | With/without skill comparison |

## Workflows

| Workflow | Scenario | Trigger |
|----------|----------|---------|
| Full Creation | Build a new skill from zero | "create a skill", "new skill" |
| Quick Audit | Check an existing skill's quality | "audit this skill", "quality check" |
| Trigger Optimization | Improve trigger word accuracy | "optimize triggers", "trigger test" |
| Security Review | Pre-publish safety check | "security scan", "pre-publish check" |
| Eval Testing | Quantify skill effectiveness | "run eval", "test accuracy" |

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/mupoet/mu-skill-creator.git

# 2. Run audit on any skill
bash scripts/skill-audit.sh <skill-name>

# 3. Follow the 8-stage workflow to create your first skill
# Read SKILL.md for the complete guided process
```

## Technical Specs

| Item | Description |
|------|-------------|
| Architecture | 3-Layer (L1/L2/L3) with gated stages |
| L2 Budget | ≤300 lines (official 500, conservative 300) |
| Audit Script | Bash, requires Python 3 for IRON LAW analysis |
| Anti-Patterns | 20 documented patterns with fix recipes |
| Eval Framework | With/without comparison, ≥85% accuracy gate |
| Stall Detection | stale_count mechanism, max 15 rounds/30 min |

## Security & Privacy

- All processing happens locally — no data leaves your machine
- Security scan detects hardcoded credentials, API keys, and PII
- Sensitive system URL blacklist prevents accidental API exposure
- User data isolation rules prevent publishing personal files
- No telemetry, no tracking, no external data collection

## Star History

If this quality framework saved you from publishing a broken skill, consider giving it a ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=mupoet/mu-skill-creator&type=Date)](https://star-history.com/#mupoet/mu-skill-creator&Date)

## Author

**木老师 (Mr. Mu)**

Builder of AI agent skills and quality frameworks. Believes that good tooling should make bad output structurally impossible, not just discouraged.

- GitHub: [@muippt](https://github.com/mupoet)

## License

[MIT](LICENSE) © 2025 木老师 (Mr. Mu)

Built on insights from hundreds of real-world AI agent skill development iterations. Special thanks to the CatPaw/CatDesk community for battle-testing these quality patterns.

> Note: Much of this project was co-created with AI assistance. If you believe your work has been used without proper attribution, please open an issue.

---

> Because "it looks fine" is not a quality gate.
