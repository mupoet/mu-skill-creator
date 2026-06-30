# 推荐联动指南

## mu-dev-workflow：管理开发节奏

创建 Skill 本质上也是软件开发，推荐与 `mu-dev-workflow` 配合使用：

| 阶段 | mu-skill-creator | mu-dev-workflow |
|------|-----------------|-----------------|
| 需求/设计 | 阶段1~2（收集输入输出示例、规划结构） | 阶段1~2（需求澄清、设计文档） |
| 质量预检 | 阶段6~7（可验证性审查、Eval测试6.5可选、触发词优化） | **阶段2.5**（Skill质量门控预检） |
| 执行实现 | 阶段4~5（写L2/L3） | 阶段3~4（计划分解、子Agent执行） |
| 验收收尾 | 阶段8（发布四步） | 阶段5（Verification Checklist） |

**推荐用法**：用 `mu-dev-workflow` 管理整体任务节奏和子Agent调度，用 `mu-skill-creator` 聚焦 Skill 内容质量。

## mu-skill-shrimp（技能虾）：管理与上架 Friday 广场

Skill 写完后，用 `mu-skill-shrimp` 完成广场管理：

**mu-skill-creator** 写好内容 + 信安扫描 + 打包；**mu-skill-shrimp** push上架、搜索、安装/卸载/回滚、标签管理、版本迭代。详见 [publish-workflow.md](publish-workflow.md)
