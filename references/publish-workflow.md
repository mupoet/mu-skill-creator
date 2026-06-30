# 美团 Skill 四步发布完整版

> 来源：内部 Skill 发布规范（权威来源）
> ⚠️ 所有 `--app-auth` 示例中，appkey 和 secret 均为占位符，真实值通过命令行传入，禁止写入文件

---

## 硬规则速查（不可违反）

| # | 规则 | 违反后果 |
|---|------|---------|
| 1 | **发布需明确授权**：必须等木老师说"可以发布"才执行 publish/push | 白干 |
| 2 | **SKILL.md 中禁止出现真实 appkey** | 信安拦截 |
| 3 | **`--intro auto` 已死**：必须手动传三段式文本 | 广场简介显示触发器文本 |
| 4 | **description ≠ intro**：内容完全不同 | Agent 触发率下降 |
| 5 | **发布后禁止猜 id**：必须 `skill-cli search` 查真实数字 | 链接 404 |
| 6 | **zip + 说明必须两条分开发** | 木老师收不到文字 |
| 7 | **`--intro` 换行符必须用 printf**：dash 不解析 `\n` | 广场显示 `\n` 字面量 |

---

## SKILL.md frontmatter 规范

```yaml
---
name: mu-<skill-name>
version: x.y.z
description: "单行触发器，双引号，不换行。做什么+触发词+不适用"
# appkey: <your-appkey>    # ⚠️ 真实值禁止出现！只写占位符或删除此行
tags: 标签1,标签2,标签3,标签4,标签5,标签6   # ≥6个，逗号分隔，无空格
visibility: public
---
```

---

## Step ①：安全扫描

```bash
cd <skill-dir>

echo "=== ① 人员信息 ==="
grep -rn "@your-corp\.com\|empId:[0-9]\|userId:[0-9]\|MIS:[a-z]" \
  SKILL.md scripts/ references/ assets/ 2>/dev/null

echo "=== ② 组织/规模 ==="
grep -rn "[0-9]\{2,4\}人\|HC.*[0-9]\+个\|BG-[0-9]" \
  SKILL.md scripts/ references/ assets/ 2>/dev/null

echo "=== ③ 凭证/AppKey ==="
grep -rn "client_secret\s*=\s*['\"][^'\"<]\|Bearer [A-Za-z0-9]\{20,\}\|token\s*=\s*['\"][^'\"<]\|^appkey:\s*[0-9A-Za-z]\{10,\}" \
  SKILL.md scripts/ references/ assets/ 2>/dev/null

echo "=== ④ 内网地址 ==="
grep -rn "10\.[0-9]\+\.[0-9]\+\.[0-9]\+\|192\.168\.[0-9]\+\|172\.(1[6-9]\|2[0-9]\|3[01])\.[0-9]\+\.[0-9]\+\|internal\.(corp\|local\|intranet)" \
  SKILL.md scripts/ references/ assets/ 2>/dev/null

echo "=== ④b 受限系统（禁止Skill调用） ==="
echo "# 添加你的组织内部系统域名模式，例如:"
echo "# grep -rn 'internal.your-corp.com|hr.your-corp.com|admin.your-corp.local' SKILL.md scripts/ references/ assets/ 2>/dev/null"

echo "=== ⑤ cron/脚本硬编码用户名 ==="
grep -rn "\-\-user [a-z]\{3,\}\|\-\-mis [a-z]\{3,\}\|\-\-appkey [a-z]\{3,\}" \
  SKILL.md scripts/ references/ assets/ 2>/dev/null

echo "=== ⑥ .git 目录 ==="
ls -la .git 2>/dev/null && echo "⚠️ 存在，打包时必须排除" || echo "✅ 无"
```

**规则**：有任何命中 → 修改 → 重扫 → 全部通过才能进 Step ②

---

## Step ②：frontmatter 校验

手动检查以下项：
- [ ] `name` 有 `mu-` 前缀
- [ ] `description` 双引号单行（触发器，无 emoji，有触发词+不适用）
- [ ] **无真实 appkey**（写占位符 `<your-appkey>` 或删掉此行）
- [ ] `tags` ≥6 个，逗号分隔，无空格
- [ ] `visibility: public`

---

## Step ③：打包 + 发说明

```bash
# 打包（必须 cd 进 skill 目录，根目录直接是 SKILL.md）
cd <skill-dir>
zip -r /tmp/mu-<name>.zip SKILL.md scripts/ references/ assets/ 2>/dev/null || \
zip -r /tmp/mu-<name>.zip SKILL.md

# 验证结构（第一条必须是 SKILL.md，不能是 mu-name/SKILL.md）
unzip -l /tmp/mu-<name>.zip | head -5
```

**发送规则（必须两条分开，顺序不能错）：**

```python
# 第一条：zip 附件
message(action=send, channel=messaging-platform, media="/tmp/mu-<name>.zip", filename="mu-<name>.zip")

# 第二条：单独发三段式说明（先文件后文字）
message(action=send, channel=messaging-platform, message="<三段式说明文本>")
```

> ⚠️ 两条全发完才算 Step ③ 完成，缺一条不得继续

---

## Step ④：推送到广场

**首次发布（新 Skill）：**
```bash
skill-cli publish <dir-name> --visibility public --appkey <your-appkey>
```

**更新已有 Skill：**
```bash
# ⚠️ intro 换行符必须用 printf，禁止在双引号里直接写 \n
INTRO=$(printf '🛠️ 一句话核心价值\n\n【主要适用场景】\n1、场景一\n2、场景二\n3、场景三\n\n【功能亮点】\n1、🧱 功能一\n2、🛡️ 功能二')

skill-cli push <dir-name> \
  --intro "$INTRO" \
  --app-auth "<your-appkey>,<your-secret>" \
  --version-description "本次更新说明"
```

---

## 发布后验证（全部完成才算上线）

```bash
# 1. 查真实 id（禁止猜测）
skill-cli search <name> --appkey <your-appkey> 2>&1 | grep "^id:"

# 2. 拼链接（唯一正确格式）
# https://skill-marketplace.example.com/skills/skill-detail?id=<真实id>&activeTab=overview
```

| 检查项 | 操作 | 期望 |
|--------|------|------|
| 广场可搜到 | `skill-cli search <name>` | 有结果 |
| 简介已更新 | browser-automation-tool 打开详情页"简介"tab | 三段式 intro，非触发器文本 |
| 信安徽章 | browser-automation-tool 截图详情页 | 两个绿色徽章 |
| 广场分类标签 | 浏览器编辑页手动勾选 | 对应分类已勾 |

> 🔴 信安/平台检测任一为红 → 立即自查修复，不等木老师发现

发完广场链接通知木老师：`✅ 已上线广场：[mu-xxx](https://skill-marketplace.example.com/skills/skill-detail?id=<id>)`

---

## 常见踩坑（历史血泪）

| 坑 | 表现 | 正确做法 |
|----|------|---------|
| SKILL.md 含真实 appkey | 信安拦截 | appkey 字段删掉或写占位符 |
| `--intro auto` | 广场显示触发器文本 | 手动传三段式 |
| `--intro "...\n..."` | 广场显示 `\n` 字面量 | 用 `printf` 生成换行再传 |
| 发布后猜 id | 链接 404 | `skill-cli search` 查真实 id |
| zip 根目录多套一层 | 安装后目录结构错 | `cd` 进 skill 目录再 zip |
| zip + 说明合并一条发 | 木老师收不到文字 | 两条分开发，先文件后文字 |
| 第三方 Skill 跳过扫描 | 可能带入内网信息 | 四步流程一视同仁 |
