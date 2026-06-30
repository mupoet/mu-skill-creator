---
name: mu-skill-creator
version: 3.0
description: "Skill创建与质量门控，含49项10层审计模型。触发词：创建skill、skill创建、skill审计、质量审计。不适用：skill发布、生态体检（用mu-skill-auditor）"
tags: Skill开发,质量门控,发布流程,三层模型,美团规范,工作流
visibility: public

---
**IRON LAW:1改完 Skill 必须立即跑 skill-audit 全绿才算完成,禁止"目测没问题"就交付;2description 只给 Agent 读(触发器),intro 只给人看(广场简介),两者不可混用;3安全扫描未通过禁止 push,人员/组织/薪酬/职级信息禁止进任何 Skill 文件;4IRON LAW 必须是该 Skill 的业务专属约束,禁止只写行数/凭据等通用套话。**

## §1 Motivation：为什么需要这个 Skill

Skill 质量劣化有三个系统性失效模式，所有规则都针对它们：

1. **规则遗忘**——小改动不检查→质量劣化在缝隙中发生。根因：没有强制审计闭环，"目测没问题"成了默认行为。
2. **规则冲突**——新增规则与旧规则矛盾→Agent 执行时选错。根因：规则分散无全局校验，改一处忘同步另一处。
3. **规则膨胀**——什么都想管→300行溢出→有效指令被挤出 context。根因：缺少拆分约束和优先级判断，"写了=管了"的幻觉。

三条共同根因：缺少工程脚手架，不是 Agent 能力不足。每条规则都应可追溯到「哪次事故催生了它」。

## §2 生态分工

| Skill | 职责 | 何时用它 |
|---|---|---|
| **mu-skill-auditor** | 诊断：六模块体检 + 降本决策 | skill体检/预算/僵尸/description超胖 |
| **mu-skill-creator** | 创作：新建/优化 Skill 内容 | 要写新 Skill 或改 SKILL.md 正文 |
| **mu-skill-shrimp** | 发布：广场上架/安装/卸载 | 要发布、安装、更新 Skill |
| **mu-skill-hunter** | 搜索：外部 GitHub/ClawHub 发现 | 要找外部没安装过的 Skill |
| **mu-self-tuning** | 策略：整体 token 降本 + 工作区养护 | 要制定降本计划/全局评分 |

## §3 核心设计决策

三决策解释了「为什么用这个架构」，每条对抗至少一个失效模式：

1. **三层模型 > 单文件**——L1(description)始终加载、L2(SKILL.md≤300行)激活时加载、L3(references/)按需加载。WHY：控制 context 膨胀，对抗**规则膨胀**（失效3）。

| 层级 | 内容 | 预算 | 加载时机 |
|------|------|------|---------|
| **L1** | 触发词 + 使用/跳过条件 | ~100词 | 始终 |
| **L2** | 工作流、原则、速查表 | ≤300行 | 激活时 |
| **L3** | 详细文档、schema、示例 | 不限 | 按需read |

L1：唯一触发机制，倾向"宁多触发别漏"(漏触发=Skill不存在，误触发可纠正)
L2：≤300行(官方建议500，取300留余量)，引用仅一级(WHY:超注意力预算→指令被挤出)。⚠️拆分用对刀:效果不减才可拆——需多一次read才能执行=拆分即质量降级
L3：每主题一文件，超100行加索引

2. **阶段门控 > 线性流程**——每个阶段有独立入口/出口条件，未满足不可跳过。WHY：对抗**规则遗忘**（失效1），门控是结构约束不是"建议"。

3. **审计脚本+清单 > 人工目测**——自动化扫描+49项10层逐项确认。WHY：目测=遗漏，脚本=可重复。对抗**规则遗忘+规则冲突**（失效1+2），跨章节一致性只能靠脚本校验。

## §4 设计原则

> 分正向（怎么做好）和防御（怎么防坏）两个视角，适用于所有 Skill。每条原则下方标注对应的 AP 反模式。

### 正向设计

1. **状态外置优于上下文累积**：进度写文件不写对话，fresh session 注入状态（WHY:上下文累积=认知死循环主因 | 对应:AP-12循环无终止）
2. **执行与评估分离**：干活的不评判进度，编排层基于量化指标判断（WHY:自评=运动员兼裁判 | 对应:AP-5无完成门控）
3. **方向差异化优先于深度挖掘**：多候选方向时优先增加多样性（WHY:多样性是逃出局部最优的唯一路径 | 对应:AP-12循环无终止——同一方向反复=停滞）
4. **每次迭代必须有可验证产出**：不是「做了」而是「产出了什么、能验证什么」（WHY:无产出=停滞前兆 | 对应:AP-6不可验证指令）

### 防御设计

5. **规则必附事故来源**：IRON LAW/Gotcha/AP 每条补「来自XX事故」（WHY:理解事故>死记禁止令 | 对应:AP-19规则只有MUST没WHY）
6. **职责隔离靠约束不靠自律**：不该做X是让结构上做不了，不是写「别做」（根因:Guardian越界→上下文污染 | 对应:AP-7无Confirmation Gate——用门控而非"建议确认"）
7. **假设每层都会失败**：单点可能挂，确保有独立恢复路径（根因:Cron超时无人知 | 对应:AP-12循环无终止——无终止条件=单点失败无恢复）
8. **停滞检测用量化指标**：用可度量信号判断卡住，不靠主观判断（根因:6/17串行超时 | 对应:AP-12循环无终止——stale_count是量化终止条件）
9. **已知局限必须诚实披露**：SKILL.md加`## 已知局限`段（WHY:沉默=误导 | 对应:AP-6的镜像——不只验证"做对了什么"还要声明"做不了什么"）

### 停滞检测规则

> 适用于所有含循环/迭代/Cron的 Skill。

| 信号 | 规则 |
|------|------|
| 单次迭代0新产出 | stale_count+1 |
| stale_count≥2 | 换结构约束（不是调参数） |
| stale_count≥4 | 上报人类 |
| 单阶段超过15轮或30分钟 | 强制换方向 |
| Cron连续2次失败 | 自动降级（如切备用API） |
| Cron连续4次失败 | 停止+上报人类 |

**"换结构不是调参数"**：当任务在同一框架内反复停滞，决定性收益来自修正环境/结构约束本身，不是在现有框架里更用力调参。

## §5 创作工作流

> **自动触发**：新建Skill→完整流程(阶段1→8) | 修改→10层审计模型+行数+AP | 发布前→完整检查+安全扫描
> **禁止**：改完不audit就提交 | 只目测不逐项过Checklist | 用系统自带版`/app/skills/skill-creator/`替代本Skill

### 阶段 1:理解需求

**入口**：收到Skill创建/优化需求

**操作**：
- **从对话中提取**：若当前对话已包含完整工作流，优先从聊天历史提取——工具链、步骤、纠正点、I/O格式，提取后请用户确认
- 收集 3+ 输入→输出示例(真实场景,不是假设)
- 明确 Skill 类型：工具封装 / 流程引导 / 知识编码 / 检阅类
- 确认不适用场景(description 里必须写)

**出口**：有明确输入输出示例清单≥3条

### 阶段 1.5:找实践案例(非工具封装类必做)

**入口**：阶段1完成,且非纯工具封装
**操作**：黄金案例3+/失败案例5+/有效-无效对比≥1组
**出口**：有案例清单,或"工具封装型,已跳过"

### 阶段 1.6:SSO 认证方案(涉及内部API必做)

> 完整规范见 [references/sso-compliance-guide.md](references/sso-compliance-guide.md)

**入口**：Skill 需调用组织内部服务(*.<your-organization-domain>)

**操作**：读sso-compliance-guide→确认client_id→选接入方式→**硬规则**:token禁明文落盘|Cookie禁硬编码client_id|frontmatter禁放凭据|audience≤5

**出口**：认证方案确定+通过A01~A06/B01~B03，或标注"无需内部API,已跳过"

### 阶段 2:规划

**入口**：阶段 1(含1.5/1.6)完成

**操作**：
- 选意图模式：工具封装 / 生成器 / 检阅器 / 流水线 / 路由分发
- 选架构模式(可组合)：顺序工作流 / 多MCP协调 / 迭代精化 / 上下文路由 / 领域知识嵌入
- 列文件树(SKILL.md + references/ + scripts/ + assets/)
- 长流程Skill(≥4阶段)：定义 progress.json 字段（状态外置，对抗context压缩后丢失进度）

**出口**：文件树清单已确认,架构模式已选定

### 阶段 3:写 L1(description)

**入口**：阶段 2 完成

**操作**：
- 写触发词+使用/跳过条件,双引号单行≤1024字符
- **禁止**：emoji、工作流描述、宣传语（放intro）(WHY:description是路由触发器不是广告)
- **必须**：含"不适用"场景(WHY:明确边界防误触发)
- **⚡ Pushy 原则**：Claude系统性偏向undertrigger，加「即使没提X，只要提到Y也要用」

格式：`"做什么功能。触发词:词1、词2、词3。不适用:场景描述(用哪个替代)。"`

### 阶段 4:写 L2(SKILL.md)

**入口**：阶段 3 完成

**操作**：
- IRON LAW按需添加：有高频违规风险时才写，内容必须是业务专属约束，不写比写套话强(WHY:套话占行数不激活场景)
- 如有IRON LAW，放frontmatter之后第一位(WHY:Agent第一眼=硬约束)
- 每个阶段：编号+入口条件+操作步骤+出口条件
- 改动类→**Confirmation Gate**(实施前用户确认)
- 输出前→**Pre-Delivery Checklist**(可逐项打勾)
- 行数≤300；超出移到references/(WHY:超注意力预算→指令被忽略)
- **Explain WHY**：重要规则附WHY。纯MUST/NEVER/ALWAYS=yellow flag
- **Gotchas section**：环境里反直觉事实集中写进SKILL.md，单位token价值最高
- **Specificity to fragility**：越不可逆越精确(给命令/模板)；越灵活越说明意图让Agent自主发挥
- **子Agent执行规范**(流水线/多步骤必做)：SKILL.md含`## 子Agent最小执行规范`(≤30行)：必读文件+硬Gate+格式约束+禁止行为
- **已知局限段**：SKILL.md加`## 已知局限`，声明什么做不到/什么条件退化(WHY:沉默=误导)

**出口**：`wc -l SKILL.md`≤300，有Checklist(IRON LAW按需)

**frontmatter字段**：`name`(必填,小写+数字+连字符,与目录名一致) | `description`(必填,≤1024字符,含触发词+不适用+pushy) | `compatibility`(可选) | `metadata`(可选)

### 阶段 5:写 L3(references/)

**入口**：阶段 4 完成

**操作**：每主题一文件 | 引用仅一跳(禁A→B→C)(WHY:多跳=token膨胀+遗忘指令) | 底部建索引

**出口**：所有引用文件存在，SKILL.md有索引

### 阶段 6:可验证性审查

**入口**：阶段 5 完成

**操作**：逐条审查指令，确认可yes/no判断。❌"写高质量代码"→✅"lint通过无error"

**出口**：无主观指令，全部可yes/no判断

### 阶段 6.5:Eval 测试(可选但推荐)

**入口**：阶段 6 完成

**操作**(详见[references/quality-gates.md](references/quality-gates.md))：写2-3个prompt→evals/evals.json，spawn两组(cleanup=delete，最多4并发)，accuracy≥85%。⚠️定性类Skill(写作/面评/引导)豁免量化，改用人工审查(WHY:强行量化=造假断言)

**出口**：evals.json存在且accuracy≥85%；或标注"已跳过"/"定性类,人工审查"

### 阶段 7:触发词优化

**入口**：阶段 6.5 完成(或跳过)

**操作**(详见[references/quality-gates.md](references/quality-gates.md))：扫禁止词(analyzer/helper/tools/assistant/单独skill/短动词/≤2字) | 中英文触发词5+种 | 测试10+10触发/不触发，accuracy≥85% | 调试:问Agent「什么时候用这个Skill?」——回答不准=description需优化

**出口**：无禁止词，中英文覆盖，accuracy≥85%

### 阶段 8:发布(美团四步)

**入口**：阶段7完成+**木老师明确授权发布**

⚠️ **Confirmation Gate:发布前必须获得木老师明确的"可以发布"指令**

完整流程见[references/publish-workflow.md](references/publish-workflow.md)：
1.安全扫描(人员/凭证/内网/appkey)→ 2.frontmatter校验→ 3.打包+说明→ 4.push到广场(`skill-cli push`+`--intro`)

**出口**：广场可搜到，信安徽章双绿，简介显示三段式intro

## §6 安全硬规则

> **禁止进任何Skill文件**：人才标准/组织信息/角色指南/职级定义/人员信息(姓名/MIS/empId)/C4高敏数据
> **受限系统黑名单**(禁止调用API)：HR/绩效/人才/OKR等内部敏感系统域名（禁止直接调用API）
> **用户态数据隔离**：本地已安装列表/用户偏好/快照/推荐历史等个性化文件**禁止随Skill发布**，必须`.skillignore`排除+SKILL.md声明"首次使用自动生成"(根因:发布者数据污染下载用户行为)
> **正确做法**：Skill只写"运行时现读"指令(contentId/学城链接)，内容不进Skill。违反=信安泄密+发布拦截

## §7 Anti-Pattern 清单(AP-1~32)

> 完整说明+修复示例见[references/quality-gates.md](references/quality-gates.md)。每条标注根因事故和对应的设计原则。

| # | 反模式 | 修复 | 根因事故 | 对应原则 |
|---|--------|------|---------|---------|
| 1 | >250行 | 拆references/;效果优先 | 猎手418行Agent忽略后半段 | §3决策1 |
| 2 | description写宣传语 | description=仅触发条件 | description写"高效便捷"无法触发 | §4正向4 |
| 3 | 阶段无编号/出口 | 加编号+完成定义 | 子Agent跳步无法判进度 | §3决策2 |
| 4 | 多跳引用A→B→C | 仅一跳 | 面评虾3层嵌套Agent遗忘 | §3决策1 |
| 5 | 无完成门控 | 加验证步骤 | audit跑完不确认就交付 | §4正向2 |
| 6 | 不可验证指令 | 改yes/no可判断 | "高质量面评"Agent自认合格 | §4正向4 |
| 7 | 无Confirmation Gate | 改动前加用户确认 | 6/22未等确认自作主张发布 | §4防御6 |
| 8 | 无Pre-Delivery Checklist | 输出前加打勾清单 | 发布后才发现漏安全扫描 | §4防御7 |
| 9 | IRON LAW是套话 | 改专属约束;无风险则删 | 多个Skill写"shebang+行数"被忽略 | §1失效3 |
| 10 | 无AP列表 | 加禁止行为清单 | 新Skill反复犯同类错误 | §4防御5 |
| 11 | 无子Agent执行规范 | 加≤30行最小规范 | 子Agent跳步/自创格式 | §4防御6 |
| 12 | 循环无终止条件 | 加max/超时退出 | 6/17串行CLI无上限超时 | §4防御7+8 |
| 13 | 无数据量限制 | 加limit/截断/分页 | 小雷达91条串行查询超时 | §3决策1 |
| 14 | 冗余重复提示 | 同一指令只写一处 | SKILL.md+references两处写同一规则 | §1失效2 |
| 15 | 大文件无截断 | 加字数/行数上限 | read大文件context溢出 | §3决策1 |
| 16 | SKILL.md留intro | intro只通过push管理 | 修改SKILL.md的intro线上没同步 | §1失效2 |
| 17 | Shell无shebang/set-euo | 加shebang+安全开关 | 脚本静默失败Agent以为成功 | §4防御7 |
| 18 | 重复造轮子 | bundle到scripts/复用 | 多Skill各自SSO换票改一处漏一处 | §1失效2 |
| 19 | 规则只有MUST没WHY | 附WHY解释意图 | Agent死记禁止令遇边界选错 | §4防御5 |
| 20 | IRON LAW照搬通用模板 | 必须含业务专属约束 | IRON LAW5条套话Agent全忽略 | §1失效3 |
| 21 | frontmatter含真实MIS | 删除metadata块 | 公开Skill暴露发布者MIS | §6安全 |
| 22 | _meta.json含凭据未排除 | .skillignore排除 | 打包含真实appkey | §6安全 |

> AP-23~32: 代码质量反模式(eval/exec/异常宽度/调试残留/废弃API/契约不一致/import不匹配/无fallback/路径替换/遍历无上限/.gitignore缺失)，详见[references/quality-gates.md](references/quality-gates.md)
> 失效模式→AP: 遗忘→3/5/8/17/25 | 冲突→4/14/16/18/27 | 膨胀→1/9/13/15/20/31 | 跨模式→6/7/10/11/12/19/23/24/26/28/29/30/32

## §8 质量审计：10层模型

> 运行：`bash scripts/skill-audit.sh <skill-name>`（在 Skill 目录下执行）
> 支持环境变量 `SKILL_BASE` 指定 Skills 根目录（默认从脚本位置自动探测）
> 完整说明见 [references/quality-gates.md](references/quality-gates.md)

| 层 | 审计目标 | 项数 | 自动 | 覆盖范围 |
|---|---|---|---|---|
| L1 | 文档结构 | 6 | 4 | frontmatter/desc/name/行数/refs索引 |
| L2 | 架构一致性 | 5 | 2 | 逻辑闭环/阶段编号/跨章节/交互/版本号 |
| L3 | 代码质量 | 8 | 6 | API契约/eval/异常/调试残留/废弃API/shebang/硬编码/退化 |
| L4 | 跨文件一致性 | 3 | 0 | 模板双源/信息冗余/共享模式 |
| L5 | 文档↔代码对齐 | 2 | 2 | 参数表一致/功能路由完整 |
| L6 | 依赖完整性 | 3 | 2 | import↔requirements/技术栈/fallback |
| L7 | 文件卫生 | 6 | 5 | 僵尸/断链/孤儿/用户态/.gitignore/平台产物 |
| L8 | 安全合规 | 4 | 3 | 安全扫描/SSO/MIS/凭据 |
| L9 | 健壮性&降级 | 7 | 1 | 降级链/确认门/子Agent/数据量/大文件/路径/遍历 |
| L10 | 内容质量 | 5 | 1 | 可验证性/AP清零/文案/已知局限/停滞 |
| **合计** | | **49** | **26** | |

**逐项清单**(🔍=脚本可查,👤=人工判断)

**L1文档结构**: 🔍L1-1 IRON LAW(frontmatter后,业务专属) | 🔍L1-2 desc(单行无emoji+触发词+不适用) | 🔍L1-3 intro(三段式≠desc,tags≥6) | 🔍L1-4 name(小写+连字符=目录名) | 🔍L1-5 行数≤300 | 👤L1-6 refs索引完整
**L2架构一致性**: 👤L2-1 逻辑冲突(新旧矛盾/因果闭环) | 🔍L2-2 阶段编号+入口/出口+可验证 | 👤L2-3 跨章节(原则↔AP↔事故) | 👤L2-4 交互一致(多模式无矛盾) | 👤L2-5 版本号匹配
**L3代码质量**(scripts/): 🔍L3-1 API契约(签名↔调用) | 🔍L3-2 无eval/exec | 🔍L3-3 异常宽度(无bare except) | 🔍L3-4 无调试残留 | 🔍L3-5 无废弃API | 🔍L3-6 shebang+set-euo | 👤L3-7 硬编码已参数化 | 👤L3-8 功能退化
**L4跨文件一致性**: 👤L4-1 模板双源(不双存) | 👤L4-2 信息冗余(清单未被覆盖) | 👤L4-3 共享模式一致(utils用法)
**L5文档↔代码**(scripts/): 🔍L5-1 参数表一致(SKILL↔CLI) | 🔍L5-2 功能路由完整(均有实现)
**L6依赖完整性**(scripts/): 🔍L6-1 import↔requirements匹配 | 👤L6-2 技术栈表一致 | 🔍L6-3 可选依赖有fallback
**L7文件卫生**: 🔍L7-1 僵尸文件(refs有引用) | 🔍L7-2 断链(引用均存在) | 👤L7-3 路径孤儿(改名同步) | 👤L7-4 用户态未混入 | 🔍L7-5 .gitignore(scripts/时) | 🔍L7-6 无平台产物
**L8安全合规**: 🔍L8-1 安全扫描(appkey/MIS/C4/受限系统) | 👤L8-2 SSO方案 | 🔍L8-3 frontmatter无MIS(AP-21) | 🔍L8-4 _meta.json已排除(AP-22)
**L9健壮性&降级**: 👤L9-1 降级链(外部依赖有处理) | 👤L9-2 改动类→Confirm Gate | 👤L9-3 流水线→子Agent规范 | 👤L9-4 数据量限制(AP-13) | 👤L9-5 大文件截断(AP-15) | 🔍L9-6 路径安全(splitext) | 🔍L9-7 遍历上限
**L10内容质量**: 👤L10-1 可验证性(yes/no) | 🔍L10-2 AP清零(无AP-1~32) | 👤L10-3 文案(无错别字) | 👤L10-4 已知局限 | 👤L10-5 停滞检测(stale_count)

## §9 已知局限

1. 49项10层模型覆盖文档/代码/安全/健壮性，不能覆盖设计品味——审计全绿≠产出优秀
2. 定性类Skill审计依赖人工判断，脚本无法量化"好"
3. 触发词受Agent模型影响，不同模型可能表现不同
4. L4跨文件一致性(3项)和L10内容质量(4项)依赖人工判断，自动化率较低
5. 状态外置(progress.json)推荐非强制——短流程Skill无需

## references/ 索引

| 文件 | 说明 |
|------|------|
| [quality-gates.md](references/quality-gates.md) | AP-1~32完整说明+10层审计模型+Eval+触发词优化 |
| [publish-workflow.md](references/publish-workflow.md) | 美团四步发布(信安→校验→打包→push→验证) |
| [sso-compliance-guide.md](references/sso-compliance-guide.md) | SSO接入合规清单(A01~A06+B01~B03+C01~C03) |
| [collaboration-guide.md](references/collaboration-guide.md) | 推荐联动(mu-dev-workflow+mu-skill-shrimp) |
| [evals.json](evals/evals.json) | Eval测试用例示范 |
