# Quality Gates 质量门控完整指南

> 本文件是 mu-skill-creator 的 L3 参考文档，SKILL.md 索引指向此处。

---

## 一、AP 反模式完整说明（AP-1~32）

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
**后果**：intro 内容会随 Skill 加载进入 context，同时广场管理更难
**修复**：intro 只通过 `skill-cli push --intro` 管理，SKILL.md 不保留

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

### AP-21：frontmatter/metadata 含真实 MIS 发布
**症状**：frontmatter 中保留 `metadata.platform.creator: "your_mis"` 等字段，或类似 platform.updater / platform.skill_id 字段
**后果**：公开 Skill 发布后任何人均可看到发布者真实 MIS，造成个人信息暴露
**检查**：`grep -n 'platform.creator\|platform.updater' SKILL.md`
**修复**：删除整个 metadata 块；发布者信息由广场系统自动记录，无需手动维护

### AP-22：_meta.json 含真实凭据未排除
**症状**：Skill 目录下存在 `_meta.json`，其中含真实 appkey 或 author MIS，且没有 .skillignore 排除
**后果**：打包发布时 _meta.json 随 zip 上传，下载者可获取发布者真实 appkey
**检查**：`test -f _meta.json && cat _meta.json | grep -E 'appkey|author'`
**修复**：在 .skillignore 中加入 `_meta.json`；frontmatter 补充标准 `appkey: <your-appkey>` 占位符

### AP-23：eval/exec 执行用户输入
**症状**：脚本中使用 `eval()` 或 `exec()` 处理用户输入或外部数据
**后果**：代码注入风险，攻击者可执行任意代码
**检查**：`grep -rn 'eval(\|exec(' scripts/ --include='*.py'`
**修复**：用 AST 白名单安全评估器替代（`ast.parse` + 递归节点校验），仅允许字面量和运算符节点
**根因事故**：mu-excel-toolbox validate.py 用 eval() 执行用户传入的校验表达式

### AP-24：异常捕获过宽
**症状**：`except:` 裸捕获或 `except Exception as e:` 捕获过宽异常
**后果**：吞掉非预期错误（如 KeyboardInterrupt、SystemExit），问题被隐藏而非暴露
**检查**：`grep -rn 'except:\|except Exception' scripts/ --include='*.py'`
**修复**：缩窄 except 到具体异常类型（如 `except UnicodeDecodeError`）；确需宽捕获时至少 re-raise 或 log
**根因事故**：mu-excel-toolbox peek.py 用 `except (UnicodeDecodeError, Exception)` 吞掉所有异常

### AP-25：调试残留
**症状**：代码中残留 `if False:`、`import pdb`、`breakpoint()`、`print(调试` 等调试代码
**后果**：死代码占空间，print 污染输出，pdb 可能在生产环境阻塞
**检查**：`grep -rn 'if False\|import pdb\|breakpoint()\|print(.*debug' scripts/ --include='*.py'`
**修复**：删除所有调试残留；需要保留的调试代码用 `if DEBUG:` 环境变量门控
**根因事故**：mu-excel-toolbox dedup.py 残留 `if False:` 调试分支和未使用变量

### AP-26：废弃 API 调用
**症状**：调用了已标记 deprecated 的库 API
**后果**：未来版本升级后代码报错；部分废弃 API 已知有 bug 不会被修复
**检查**：查看库文档的 deprecation warning，或运行 `python -W all script.py` 检查警告
**修复**：替换为文档推荐的新 API
**根因事故**：mu-excel-toolbox clean.py 使用 pandas 已废弃的 `infer_datetime_format=True` 参数

### AP-27：API 契约不一致
**症状**：函数/方法的调用方传参与定义方签名不匹配（如漏括号、多余 kwargs）
**后果**：运行时 TypeError 或静默返回错误结果
**检查**：`grep -rn 'has_errors\|has_warnings' scripts/ --include='*.py'` 检查方法调用是否带括号；对比函数定义与调用
**修复**：修正调用方签名，确保参数名和数量匹配定义方
**根因事故**：mu-excel-toolbox chart.py/pivot.py 调用 `has_errors` 漏括号（属性访问 vs 方法调用）；formula.py 传无效 kwargs

### AP-28：import 与 requirements 不匹配
**症状**：脚本中 `import` 了第三方库，但 requirements.txt 中未声明；或反之
**后果**：新环境安装后运行报 ImportError；或安装了无用依赖增加体积
**检查**：提取脚本中的 import 语句，与 requirements.txt 交叉比对
**修复**：同步 requirements.txt，确保所有第三方依赖均已声明且版本固定
**根因事故**：mu-excel-toolbox convert.py 使用 tabulate 但 requirements.txt 未声明

### AP-29：可选依赖无 fallback
**症状**：使用了非核心依赖（如 `df.to_markdown()` 依赖 tabulate），但没有 try/except ImportError 处理
**后果**：用户未安装可选依赖时整个脚本崩溃，而非降级运行
**检查**：对非核心 import 检查是否有 `try: import xxx except ImportError` 包裹
**修复**：用 try/except ImportError 包裹可选依赖 import，提供降级方案（如回退到 to_string）
**根因事故**：mu-excel-toolbox convert.py/utils.py 的 markdown 格式输出无降级处理

### AP-30：路径操作字符串替换
**症状**：用 `filename.replace('.xlsx', '_chart.xlsx')` 等字符串替换操作处理文件路径
**后果**：文件名含多个 `.xlsx` 时误切；跨平台路径分隔符不一致
**检查**：`grep -rn "\.replace('\..*','" scripts/ --include='*.py'`
**修复**：使用 `os.path.splitext()` 分离扩展名，再拼接新后缀
**根因事故**：mu-excel-toolbox chart.py 用 `.replace('.xlsx', '_chart.xlsx')` 生成输出文件名

### AP-31：资源遍历无上限
**症状**：遍历大文件/大数据集的循环没有行数/条数上限
**后果**：遇到百万行数据时遍历超时或内存溢出
**检查**：审查 `for` 循环遍历 DataFrame/文件的代码段，检查是否有 `[:limit]` 或 `break` 条件
**修复**：加采样上限（如 `col[:101]` 只取前100行计算），或加分页/分块逻辑
**根因事故**：mu-excel-toolbox style.py 自动列宽遍历全部行（百万行时超时）

### AP-32：.gitignore 缺失
**症状**：Skill 含 scripts/ 目录但无 .gitignore 文件
**后果**：`__pycache__/`、`.pyc`、`.DS_Store` 等产物随发布上传，污染下载者环境
**检查**：`test -d scripts/ && test -f .gitignore || echo 'MISSING'`
**修复**：创建 .gitignore，至少排除 `__pycache__/`、`*.pyc`、`.DS_Store`、`Thumbs.db`
**根因事故**：mu-excel-toolbox 发布前无 .gitignore，__pycache__ 随包上传

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
