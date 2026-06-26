#!/bin/bash
# skill-audit.sh — mu-Skill 结构健康检查工具
# 所属: mu-skill-creator Skill（scripts/skill-audit.sh）
# 规则来源: mu-skill-creator 质量检查清单（可自动验证的子集）
#
# 用法:
#   bash skill-audit.sh                    # 扫描全部 Skills
#   bash skill-audit.sh mu-excel-toolbox   # 只查指定 Skill（名称）
#   bash skill-audit.sh mu-a mu-b          # 查多个
#   bash skill-audit.sh --verbose          # 全部 + 详细说明
#
# 检查项:
#   IRON_LAW  - 是否在 frontmatter 之后有 IRON LAW 声明
#   IL_DIFF   - IRON LAW 内容是否差异化（不含通用套话、含至少1条Skill专属约束）
#   DESC      - description 格式（双引号单行 + 触发词 + 不适用）
#   SEC_RISK  - 是否引用了安全受限系统URL
#   LINES     - 行数（>250 标黄，信息项不阻断）

set -euo pipefail

SKILL_BASE="${SKILL_BASE:-${HOME}/.skills}"
VERBOSE=false
TARGETS=()

# 解析参数
for arg in "$@"; do
  if [ "$arg" = "--verbose" ]; then
    VERBOSE=true
  else
    TARGETS+=("$arg")
  fi
done

# 构建 SKILLS 数组：name|path
SKILLS=()

if [ ${#TARGETS[@]} -eq 0 ]; then
  # 未指定 → 自动扫描全部含 SKILL.md 的子目录
  while IFS= read -r skill_md; do
    skill_dir=$(dirname "$skill_md")
    name=$(basename "$skill_dir")
    # 跳过 _开头的目录（如 _archive）
    case "$name" in _*) continue ;; esac
    SKILLS+=("${name}|${skill_md}")
  done < <(find "$SKILL_BASE" -maxdepth 3 -name "SKILL.md" ! -path "*/_archive/*" ! -path "*/_*/*" | sort)
else
  # 指定名称 → 找对应 SKILL.md
  for target in "${TARGETS[@]}"; do
    # 先找精确匹配，再找 ppt-master 这种嵌套结构
    skill_md=$(find "$SKILL_BASE/${target}" -maxdepth 3 -name "SKILL.md" 2>/dev/null | head -1 || true)
    if [ -n "$skill_md" ]; then
      SKILLS+=("${target}|${skill_md}")
    else
      echo "❌ 找不到 Skill: $target（路径: $SKILL_BASE/$target）"
    fi
  done
fi

# 找不到任何 Skill 时早退
if [ ${#SKILLS[@]} -eq 0 ]; then
  echo "❌ 未找到任何可检查的 Skill"
  exit 1
fi

# Counters
total=0
pass=0
warn=0
fail=0

printf "%-25s %5s %8s %8s %10s %8s\n" "SKILL" "LINES" "IRON_LAW" "IL専属" "DESC" "SEC_RISK"
printf "%-25s %5s %8s %8s %10s %8s\n" "-------------------------" "-----" "--------" "--------" "----------" "--------"

for entry in "${SKILLS[@]}"; do
  IFS='|' read -r name f <<< "$entry"
  total=$((total + 1))
  
  if [ ! -f "$f" ]; then
    printf "%-25s %5s %8s %10s %8s\n" "$name" "N/A" "❌文件缺" "-" "-"
    fail=$((fail + 1))
    continue
  fi

  lines=$(wc -l < "$f")
  skill_ok=true
  
  # IRON LAW check — 存在性（无 IRON LAW 为警告而非强制失败）
  if grep -qi "IRON LAW" "$f"; then iron="✅"; else iron="⚠️建议"; fi

  # IRON LAW 差异化检查 — 有 IRON LAW 时必须是业务专属约束，不得只写通用套话
  # 通用套话特征：全是 shebang/set -euo/≤250行/不硬编码 等基础规则，无业务语义词
  il_diff="⚠️"
  if grep -qi "IRON LAW" "$f"; then
    # 提取 IRON LAW 所在行
    il_line=$(grep -i "IRON LAW" "$f" | head -1)
    # 检查是否含业务语义词（非纯基础规则）
    has_biz=$(echo "$il_line" | python3 -c "import sys,re; t=sys.stdin.read(); print(1 if re.search(r'禁止|必须|不得|告知|文档|报告|消息|触发', t) else 0)" 2>/dev/null || true)
    # 检查是否全是纯通用套话（只有 shebang/set -euo/行数/硬编码/API Key 等）
    only_generic=$(echo "$il_line" | python3 -c "import sys,re; t=sys.stdin.read(); print(1 if re.search(r'shebang|set -euo|API Key', t) else 0)" 2>/dev/null || true)
    if [ "$has_biz" -gt 0 ]; then
      il_diff="✅"
    elif [ "$only_generic" -gt 2 ]; then
      il_diff="❌套话"; skill_ok=false
    else
      il_diff="⚠️待查"
    fi
  else
    il_diff="-"
  fi
  
  # Description check: double-quoted single line + 触发词 + 不适用
  desc_line=$(grep -m1 "^description:" "$f")
  if [ -z "$desc_line" ]; then
    desc="❌缺失"; skill_ok=false
  elif echo "$desc_line" | grep -qP '^description:\s*".*"$'; then
    has_trigger=$(echo "$desc_line" | grep -c "触发词\|触发条件\|trigger" || true)
    has_exclude=$(echo "$desc_line" | grep -c "不适用\|不用于" || true)
    if [ "$has_trigger" -gt 0 ] && [ "$has_exclude" -gt 0 ]; then
      desc="✅"
    elif [ "$has_trigger" -gt 0 ]; then
      desc="⚠️无排除"; skill_ok=false
    elif [ "$has_exclude" -gt 0 ]; then
      desc="⚠️无触发"; skill_ok=false
    else
      desc="⚠️缺两项"; skill_ok=false
    fi
  else
    desc="❌格式"; skill_ok=false
  fi
  
  # Security: restricted system URLs
  sec_hits=$(grep -cE "api_key|secret|password|token|credential|private_key" "$f" 2>/dev/null || true)
  if [ "$sec_hits" -gt 0 ]; then sec="⚠️${sec_hits}处"; else sec="✅"; fi
  
  printf "%-25s %5d %8s %8s %10s %8s\n" "$name" "$lines" "$iron" "$il_diff" "$desc" "$sec"
  
  if [ "$skill_ok" = true ] && [ "$sec_hits" -eq 0 ]; then
    pass=$((pass + 1))
  elif [ "$skill_ok" = false ]; then
    fail=$((fail + 1))
  else
    warn=$((warn + 1))
  fi
done

echo ""
echo "━━━ Summary ━━━"
echo "Total: $total | ✅ Pass: $pass | ⚠️ Warn: $warn | ❌ Fail: $fail"

if [ "$VERBOSE" = true ]; then
  echo ""
  echo "规则说明:"
  echo "  IRON_LAW: SKILL.md 中包含 'IRON LAW' 关键词"
  echo "  IL_DIFF:  IRON LAW 内容差异化检查"
  echo "            ✅ 含业务语义词（禁止/必须/告知/文档/报告等），非纯通用套话"
  echo "            ❌套话 只含 shebang/set -euo/行数/硬编码 等基础规则，无 Skill 专属约束"
  echo "            ⚠️待查 无法自动判断，需人工确认内容是否与 Skill 功能相关"
  echo "  DESC: description 为双引号单行 + 含'触发词' + 含'不适用'"
  echo "  SEC_RISK: 无硬编码凭据/密钥/敏感信息"
  echo "  LINES: >250行为信息提示(IRON LAW豁免场景不阻断)"
fi

# 完整 23 项 checklist（每次都打印，不区分自动/人工）
echo ""
echo "━━━ 完整审计清单（逐项确认后再发布）━━━"
echo ""
echo "【格式规范】"
echo "  [ ] 1.  IRON LAW: frontmatter 后第一位，内容业务专属（无通用套话）；无高频违规风险可不写"
echo "  [ ] 2.  description: 单行无emoji + 触发词 + 不适用场景 | 无禁止词 | 触发词 ≤10 个"
echo "  [ ] 3.  intro: 广场三段式有emoji ≠ description，tags ≥ 6；SKILL.md 无 intro 字段"
echo "  [ ] 4.  name: 小写+数字+连字符，与目录名完全一致"
echo "  [ ] 5.  行数 ≤ 300；超限按 AP-1 拆分（效果优先，执行时需要的不可移出）"
echo "  [ ] 6.  所有阶段有编号+入口/出口条件 | 无 AP 反模式 | 指令可 yes/no 验证"
echo "  [ ] 7.  涉内部API: SSO 方案确定 + 无硬编码凭据"
echo "  [ ] 8.  改动类有 Confirmation Gate | 流水线类有子 Agent 最小规范（≤30行）"
echo "  [ ] 9.  安全: 无真实 appkey/AK/SK/cookie | 无人员信息/保密信息 | 无受限系统调用"
echo ""
echo "【结构健康】"
echo "  [ ] 10. 逻辑冲突: SKILL.md 新旧规则不矛盾？编号/数量声明与 references/ 实际一致？因果闭环：§1每个失效模式是否被后续规则全部覆盖？"
echo "  [ ] 11. 模板双源: 同一内容未在 SKILL.md 和 references/ 各存一份？"
echo "  [ ] 12. 僵尸文件: references/ 所有文件均被 SKILL.md 引用？"
echo "  [ ] 13. 断链引用: SKILL.md 引用的 references/ 文件均真实存在？"
echo "  [ ] 14. 路径孤儿: .skillignore/README/脚本里的旧路径已同步更新？"
echo "  [ ] 15. 用户态数据: 未混入已安装列表/快照/偏好等个性化文件？"
echo "  [ ] 16. 硬编码隐患: 脚本里固定路径/尺寸/ID 已参数化？"
echo "  [ ] 17. 功能退化: 本次改动未破坏已有功能？"
echo "  [ ] 18. 版本号: 改动幅度与版本号匹配？大改只加0.1 = 失真"
echo ""
echo "【内容质量】"
echo "  [ ] 19. 跨章节一致性: 上下游/联动表/正文描述三处互相对应？每条原则是否有对应AP落地？每条AP是否标注根因事故和对应原则？"
echo "  [ ] 20. 信息收集与流程冗余: 信息收集清单条目未被正文流程自动覆盖？"
echo "  [ ] 21. 交互流程内部一致性: 多模式/分支流程描述不矛盾？"
echo "  [ ] 22. 文案质量: 无明显错别字/歧义表达/前后语境矛盾？"
echo "  [ ] 23. 降级链完整性: 每个外部依赖(API/CLI/认证)均有失败场景处理，无遗漏导致流程卡死？"
echo ""
echo "全部确认后再进入发布流程。"
