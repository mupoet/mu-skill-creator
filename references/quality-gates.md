# Quality Gates 质量门控完整指南

> 本文件是 mu-skill-creator 的 L3 参考文档，SKILL.md 索引指向此处。

---

## 一、AP 反模式完整说明（AP-1~20）

### AP-1：SKILL.md > 500 行
**症状**：SKILL.md 包含大量示例代码、完整 schema、详细说明
**后果**：每次激活消耗大量 token，上下文污染
**修复**：把详细内容移到 references/ 下，SKILL.md 只留摘要 + 链接

### AP-2：description 写工作流
**症状**：description 里出现"当用户需要…时，先做A，再做B，最后做C"
**后果**：description 过长导致 agent 触发混乱，也降低可读性
**修复**：description 只写"做什么 + 触发词 + 不适用"，工作流放 SKILL.md

### AP-3：阶段没有编号/出口条件
**症状**：阶段标题有了，但没有明确"做完了是什么样"
**后果**：agent 不知道何时推进到下一阶段，容易死循环或跳步
**修复**：每个阶段加 `出口条件：xxx`，用可验证的描述

### AP-4：引用链多跳（A→B→C）
**症状**：SKILL.md 引用 references/guide.md，guide.md 再引用 detail.md
**后果**：agent 需要多次 read 才能获取信息，效率低下
**修复**：所有引用从 SKILL.md 出发，只允许一跳到 references/

### AP-5：没有完成门控
**症状**：执行完了，但没有验证步骤
**后果**：agent 自述"完成了"但实际未完成，问题无法发现
**修复**：每个关键阶段加验证步骤（运行命令，检查输出）

### AP-6：不可验证指令
**症状**：指令里有"高质量"、"合理"、"友好"等主观描述
**后果**：agent 无法判断是否满足要求，导致输出不一致
**修复**：所有指令改为可 yes/no 判断的客观标准

### AP-7：无 Confirmation Gate
**症状**：会修改文件/发消息/部署的 Skill，没有在实施前让用户确认
**后果**：误操作风险高，不可逆
**修复**：在改动步骤前加确认环节，明确列出将要做的操作

### AP-8：无 Pre-Delivery Checklist
**症状**：执行完了直接输出，没有最终检查
**后果**：遗漏细节，输出质量参差不齐
**修复**：在最终输出前加可打勾的检查清单

### AP-9：无 IRON LAW
**症状**：SKILL.md 顶部没有防抄近路的铁律
**后果**：agent 在"我觉得没问题"时跳过关键步骤
**修复**：frontmatter 之后第一行写 IRON LAW，加粗，醒目

### AP-10：无 Anti-Pattern 列表
**症状**：只告诉 agent 该做什么，没有告诉不该做什么
**后果**：agent 会用默认行为填补空白，而默认行为往往不符合期望
**修复**：显式列出 5-10 条禁止行为

### AP-11：无子Agent执行规范
**症状**：Skill 可能被子Agent执行，但 SKILL.md 中没有子Agent最小执行规范段落
**后果**：子Agent不知道哪些步骤不可跳过，默认行为填充导致关键步骤遗漏
**修复**：加 ≤ 30 行最小执行规范（必读文件/硬 Gate/禁止行为）

### AP-12：循环无终止条件
**症状**：循环逻辑没有 max 次数或超时退出条件
**后果**：Agent 可能无限重试，占用大量 token/时间
**修复**：循环内加 max 次数或超时退出逻辑

### AP-13：无数据量限制
**症状**：批量操作/输出没有 limit/截断/分页上限
**后果**：数据量大时输出内容截断或 token 爆表
**修复**：加明确的 limit 数字和分页逻辑

### AP-14：冗余重复提示
**症状**：同一条指令在 SKILL.md 不同位置重复出现
**后果**：占用行数，迭代时只改了一处导致不一致
**修复**：同一指令只写一处，其余地方用引用

### AP-15：大文件无截断
**症状**：读取或输出大文件时没有字数/行数上限
**后果**：超出 context 窗口导致内容被截断且无感知
**修复**：明确加字数/行数上限，超出时分页续读

### AP-16：SKILL.md 保留 intro 字段
**症状**：frontmatter 里写了 `intro:` 字段
**后果**：intro 内容会随 Skill 加载进入 context，同时 marketplace 管理更难
**修复**：intro should be managed through the marketplace publish command, not stored in SKILL.md

### AP-17：Shell 无 shebang/set -euo
**症状**：脚本第一行不是 shebang，或缺少 `set -euo pipefail`
**后果**：脚本执行失败时静默继续，错误难以定位
**修复**：第一行加 `#!/usr/bin/env bash`，第二行加 `set -euo pipefail`

### AP-18：重复造轮子
**症状**：多个 Skill 各自实现相同的功能脚本
**后果**：维护成本翻倍，修一处忘修其他
**修复**：抽取到 scripts/ 共用，其他 Skill 引用

### AP-19：规则只有 MUST 没 WHY
**症状**：规则只写 MUST/NEVER/ALWAYS，没有解释原因
**后果**：Agent 理解意图比死记规则更有效，缺少 WHY 导致规则被忽略
**修复**：重要规则底部附一句 WHY

### AP-20：IRON LAW 照据通用模板
**症状**：IRON LAW 内容是通用套话（行数/shebang/硬编码等），没有该 Skill 的业务专属约束
**后果**：IRON LAW 占了行数但激活不了任何防护，形同虚设
**修复**：IRON LAW 必须包含该 Skill 频率最高的违规模式和业务专属约束

### AP-21：frontmatter/metadata 含真实身份信息发布
**症状**：frontmatter 中保留 `metadata.platform.creator: "your-username"` 等字段，或类似 platform.updater / platform.skill_id 字段
**后果**：公开 Skill 发布后任何人均可看到发布者真实身份，造成个人信息暴露
**检查**：`grep -n 'platform.creator\|platform.updater' SKILL.md`
**修复**：删除整个 metadata 块；发布者信息由 marketplace system records automatically，无需手动维护

### AP-22：_meta.json 含真实凭据未排除
**症状**：Skill 目录下存在 `_meta.json`，其中含真实 API keys or author identity，且没有 .skillignore 排除
**后果**：打包发布时 _meta.json 随 zip 上传，下载者可获取发布者真实凭据
**检查**：`test -f _meta.json && cat _meta.json | grep -E 'appkey|author'`
**修复**：在 .skillignore 中加入 `_meta.json`；frontmatter 补充标准 `appkey: <your-appkey>` 占位符

---

## 二、Eval 测试框架

### 目的
通过 with/without skill 对比，量化 Skill 的实际效果。accuracy ≥85% 才算通过。

### evals/evals.json 格式
```json
[
  {
    "id": "eval-001",
    "prompt": "帮我创建一个新 Skill，用于搜索公司内部文档",
    "expected_behaviors": [
      "包含 IRON LAW",
      "description 单行无 emoji",
      "有触发词和不适用场景",
      "tags ≥ 6 个"
    ],
    "grading_criteria": "检查输出的 SKILL.md 是否满足所有 expected_behaviors"
  }
]
```

### 执行流程
```
1. 写 2-3 个真实 prompt（来自实际用户请求）
2. Spawn with-skill subagent（加载 mu-skill-creator）
3. Spawn without-skill subagent（不加载，用默认行为）
4. 每个 subagent 写 grading.json + timing.json
5. 父 session 读取两组结果，计算 accuracy
6. accuracy = (with-skill 满足的行为数) / (总行为数)
```

### 并发约束
- 每个 subagent 加 `cleanup=delete`
- 最多同时 4 个并发 subagent
- subagent 超时 10 分钟视为失败

### grading.json 格式
```json
{
  "eval_id": "eval-001",
  "with_skill": {
    "passed": ["包含 IRON LAW", "description 单行无 emoji"],
    "failed": [],
    "score": 1.0
  },
  "without_skill": {
    "passed": [],
    "failed": ["包含 IRON LAW", "description 单行无 emoji"],
    "score": 0.0
  }
}
```

---

## 三、触发词优化完整指南

### Gate 3 禁止词（硬阻断，不得出现在触发词中）

| 禁止词 | 原因 |
|--------|------|
| `以下内容` | 无意义描述，不是触发词 |
| `analyzer` | 英文通用词，触发范围过宽 |
| `helper` | 英文通用词，触发范围过宽 |
| `tools` | 英文通用词，触发范围过宽 |
| `assistant` | 英文通用词，触发范围过宽 |
| 单独 `skill` | 太宽泛，几乎所有请求都匹配 |
| 短动词（做/写/搜索） | 太通用，覆盖所有场景 |
| <2 字触发词 | 太短，误触率高 |

### 触发词测试模板

**10 个 should-trigger（必须触发此 Skill）：**
```
1. "帮我创建一个新的 skill"
2. "我想写一个 skill，用于处理XXX"
3. "优化一下这个 skill 的触发词"
4. "新 skill 怎么做"
5. "skill 开发规范是什么"
6. "帮我从头写一个 skill"
7. "skill 创作流程"
8. "想做一个新功能的 skill"
9. "skill 写完怎么发布"
10. "这个 skill 怎么优化"
```

**10 个 should-NOT-trigger（不得触发此 Skill）：**
```
1. "帮我写一段 Python 代码"
2. "修复这个 bug"
3. "帮我开发一个 Web 应用"
4. "搭建一个后端服务"
5. "写一个单元测试"
6. "重构这个函数"
7. "帮我设计数据库表结构"
8. "生成一份技术文档"
9. "翻译这段英文"
10. "帮我做一个 PPT"
```

### 准确率计算
```
accuracy = (should-trigger 正确触发数 + should-NOT-trigger 正确不触发数) / 20
```
目标：accuracy ≥ 85%（即 17/20 以上）

---

## 四、可验证性审查（主观→可验证转换示例）

### 转换原则
所有指令必须能用 yes/no 判断，而不是需要主观评估。

### 转换示例

| ❌ 主观（不通过） | ✅ 可验证（通过） |
|---|---|
| "写高质量代码" | "lint 通过，无 error；函数覆盖率 ≥70%" |
| "合理组织代码结构" | "每函数 ≤50 行；模块职责单一" |
| "友好的错误提示" | "错误信息包含：原因描述 + 修复建议 + 错误码" |
| "全面测试" | "单测覆盖率 ≥80%；有正向+边界+异常三类用例" |
| "清晰的注释" | "每个公开函数有 docstring；复杂逻辑有行内注释" |
| "性能良好" | "P95 响应时间 ≤200ms；内存峰值 ≤512MB" |
| "安全的实现" | "无 SQL 注入；输入校验覆盖所有外部来源；无明文凭据" |
| "遵循最佳实践" | "通过 ESLint/Pylint 检查；无 console.log；无 TODO 遗留" |

### 审查步骤
1. 逐条扫描 SKILL.md 中所有指令
2. 对每条指令问："这个能用 yes/no 回答吗？"
3. 不能 → 按上表模式改写
4. 全部通过 → 可验证性审查完成
