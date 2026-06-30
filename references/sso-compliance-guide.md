# SSO 合规检查清单 — Skill 接入身份体系

> 来源：[业务 Skill 接入 SSO 身份体系 — 开发者指南](https://docs.example.com/sso-guide)（企平应用平台官方）
> 最后同步：2026-04-24

---

## 一、适用范围

调用美团内部服务（`*.<your-organization-domain>`）的 Skill 必须走 SSO 标准接入。
已支持平台：Catclaw/大象个人助理 ✅ | CatPaw(含IDE) ✅ | CatDesk ✅ | Sandbox ✅ | 1024 ✅ | Friday 应用工厂 ✅

---

## 二、两种接入方式

### 方式一：Prompt 标准注入（推荐 SKILL.md prompt 驱动型）

**原理**：在 SKILL.md frontmatter 中声明 `skill-dependencies`，平台自动解析并注入 token 到占位符。

**接入步骤**：

1. **frontmatter 声明依赖**：
```yaml
---
name: my-skill
skill-dependencies:
  mtsso-skills-official:
    # 按需声明，只写实际用到的票据类型
    app_access_token_placeholder: ${app_access_token}   # 应用身份票（系统级操作）
    user_access_token_placeholder: ${user_access_token}  # 用户身份票（代表用户操作）
    audience:  # ≤5 个
      - your_skill_client_id        # 你的 Skill client_id
      - target_service_client_id    # 目标服务 client_id
    prompt: 本技能所需的token占位符，请参考mtsso-skills-official的相关说明进行获取和注入
---
```

2. **正文中使用占位符**：
```bash
# 用户票
curl -H "Authorization: Bearer ${user_access_token}" https://api.example.com/v1/data
# 或 Cookie 方式（大部分内部服务）
curl -b "${client_id}_ssoid=${user_access_token}" https://xx.example.com/api

# 应用票
curl -H "Authorization: Bearer ${app_access_token}" https://api.example.com/v1/system
```

**优势**：简单，3 分钟对接。**不足**：经过大模型推理，有一定精度/时延损耗。

### 方式二：CLI 自主集成（推荐脚本型 Skill / 追求稳定性）

**原理**：在脚本中直接调用 SSO CLI 工具获取票据。

**安装**：
```bash
npm install @mtfe/mtsso-auth-official@latest --registry http://registry.npmjs.org
```

**核心命令**：

| 命令 | 用途 | 关键参数 |
|------|------|---------|
| `npx mtsso-client-credentials` | 获取应用身份票 | `--audience "clientId_A clientId_B"` |
| `npx mtsso-moa-local-exchange` | 获取用户身份票 | `--audience "clientId_A clientId_B"`（必填） |
| `npx mtsso-token-exchange` | 换票 | `--audience` + `--subject_token` |
| `npx mtsso-introspect-token` | 解析票据 | `--token "xxx"` |
| `npx mtsso-moa-feature-probe` | 探测 MOA 是否支持本地换票 | `-t/--timeout` |

**执行示例**：
```bash
USER_TOKEN="$(npx mtsso-moa-local-exchange --audience "$AUDIENCE" | jq -r '.access_token // empty')"
[[ -n "$USER_TOKEN" ]] || { echo "access_token 为空" >&2; exit 1; }
curl -fsS "$API_URL" -H "Authorization: Bearer $USER_TOKEN"
```

**优势**：稳定、高效。**不足**：需在脚本中深度集成。

### 选择标准

| 场景 | 推荐方式 |
|------|---------|
| SKILL.md prompt 驱动，token 作为明确参数传入脚本 | 方式一（Prompt 注入） |
| 脚本内深度集成，追求稳定性和精确控制 | 方式二（CLI 集成） |
| 需要兼容多平台（CatPaw 等未完全支持时） | 方式二 + `mtsso-moa-feature-probe` 探测 |

---

## 三、合规检查项

### A 类：凭据安全

| ID | 检查项 | 合规做法 | 违规示例 |
|----|--------|---------|---------|
| A01 | Token 禁止明文落盘 | 内存缓存 + 提前刷新；用完即弃 | `echo $TOKEN > /tmp/token.txt` |
| A02 | Cookie name 不能硬编码 | 使用变量 `${client_id}_ssoid`，从配置或参数获取 client_id | `Cookie: com.example.xxx_ssoid=...`（硬编码 client_id） |
| A03 | frontmatter 禁止放凭据 | appkey/client_secret/token/cookie 实值不进 SKILL.md | `client_secret: "abc123"` 写在 frontmatter |
| A04 | 禁止 OAuth secret 硬编码 | 从环境变量或安全存储读取 | `CLIENT_SECRET="real_secret"` 写在脚本 |
| A05 | 禁止 `os.getenv("X","真实值")` 陷阱 | fallback 必须是空或报错，不能是真实凭据 | `os.getenv("TOKEN", "eyJhbGciOi...")` |
| A06 | audience ≤5 个 | 按实际需要精简 | 声明 10+ 个 audience |

### B 类：接入规范

| ID | 检查项 | 合规做法 | 违规示例 |
|----|--------|---------|---------|
| B01 | 必须使用官方 SSO 方案 | 方式一或方式二 | 自研 Cookie 捞票、自发授权卡片 |
| B02 | skill-dependencies 声明完整 | audience 包含 Skill 自身 + 目标服务的 client_id | 缺少 audience 或遗漏目标服务 |
| B03 | 票据类型按需声明 | 只声明实际使用的 app/user token | 全部声明但只用其中一种 |

### C 类：兼容性

| ID | 检查项 | 合规做法 | 违规示例 |
|----|--------|---------|---------|
| C01 | 多平台兼容探测 | 方式二中使用 `mtsso-moa-feature-probe` 判断支持情况后降级 | 不做探测直接假设可用 |
| C02 | 环境变量区分 | 使用 `MTSSO_ENV` 区分 TEST/PROD | 硬编码 prod 地址 |
| C03 | 服务端无需改造 | token 传递方式与原 ssoid 一致（Cookie/Header 视服务端而定） | 强制服务端改接口 |

---

## 四、票据说明速查

| 占位符 | 类型 | 适用场景 | sub 含义 | aud 含义 |
|--------|------|---------|---------|---------|
| `${app_access_token}` | 应用身份票 | 系统级操作，不代表具体用户 | Agent 的 clientId | audience 列表 |
| `${user_access_token}` | 用户身份票 | 代表当前用户操作 | 当前用户 mis 号 | audience 列表 |

---

## 五、FAQ 关键点

1. **Token 过期**：开发者无需管理，平台自动缓存+刷新
2. **应用票和用户票可同时声明**，用哪个触发哪个
3. **audience 来源**：目标服务的 SSO client_id（抓包 / 查 KM / 问服务方）
4. **office-cli-shared**：使用该包自动适配 SSO 无感登录，无需额外操作
5. **私有虾多人场景**：暂不支持（安全因素），后续跟进
6. **MWS/Raptor**：audience 加 `60921859`，Cookie 用 `yun_portal_ssoid="${user_access_token}"`
