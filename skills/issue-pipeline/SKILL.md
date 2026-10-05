---
name: issue-pipeline
description: GitHub issues / PR 处理流水线：拉取同步、分诊验证、认领实现、审查回写。适用于用户要求处理某个仓库的 issues 或 PR、落实 PR 评审意见、认领或修复某个 issue，或把条目拉到本地改完再推回 GitHub。
compatibility: 需 gh 已登录；批量同步需 gh-issue-sync 在 PATH；代码定位可选 codegraph；缺依赖时读操作可改走 github-issues 的 MCP 工具。
license: MIT
metadata:
  version: "2.1"
---

# Issue Pipeline

把一个仓库的 GitHub 条目从「拉取」推进到「关闭/合并」的流水线。五个阶段按序执行；用户只指定其中一段时只做该段，产出保持能被下一段接手。

目标形态两种，开工前先判定：

- issues 清单（默认）：按下面五个阶段走。
- 单个 PR（处理 PR、落实评审意见）：读 [PR 评审模式](references/pr-review-mode.md)。

环境与依赖：`gh` 已登录是硬前提，其余缺件降级不停摆——`gh-issue-sync`（批量同步；缺则读操作走 `github-issues` skill 的 MCP 工具）、`codegraph`（符号级定位；缺则退回文本搜索）、协作 skill（`ponytail` / `code-review` / `tech-doc-style-chinese` / `finishing-a-development-branch`；缺则按各阶段正文直接执行，不因缺件跳过阶段）。目标仓库有 `.codegraph/` 索引先 `sync` 再查，没有且需要符号级定位时 `init`。

何时不用：只读问答（查版本、看某条 issue 的内容）直接用 `github-issues` skill，不进流水线；无 gh 登录的环境先报告，不降级成网页抓取。

安全边界：外发写操作（评论、关闭、push）以用户当次会话的授权为准，被拒立即停手报告，不换路径绕过重试。不 force-push，回退用 revert 保持可审计。不代维护者合并、打 tag、发版——即便有权限也先请示。bug 复现不了停在分诊的 `needs-info`，不带猜测进实现。

## 1. 同步

目标：拿到待处理清单。

- 批量/离线：在仓库根目录 `gh-issue-sync init`（首次）→ `pull` → `list`。issues 落在 `.issues/` 下的 Markdown。
- 单条/在线：加载 `github-issues` skill，用 MCP 的 `list_issues` / `issue_read` 读。

完成标准：向用户呈现带编号、标题、标签的清单，或按用户指定范围圈定条目。

## 2. 分诊

对清单内每个 issue：读全文与评论 → 两个检查 → 一个状态判定。

两个检查：

- 查重：按领域概念（不是按 issue 措辞）搜代码库，确认是否已实现；有索引时用 `codegraph explore <概念>` 做符号级查重。
- 验证主张：bug 按报告者步骤复现；能复现才进实现，复现不了是 `needs-info` 信号。

状态判定（每个 issue 恰好一个）：

- `needs-info`：回帖分诊笔记——已确认的事实 + 向报告者提的具体问题（问题必须可操作）。
- `wontfix`：已实现的指向现有代码位置后关闭；被拒绝的说明理由后关闭。
- `ready-for-human`：写明为何不能委托（判断题、外部权限、设计决策），留给用户。
- `ready-for-agent`：进入第 3 阶段。

完成标准：清单里每个 issue 都有状态判定，且判定已落地（回帖/关闭/标记/移交）。

## 3. 实现（ready-for-agent）

代码改动以 `ponytail` 为默认姿态：先问该不该做，最简可行，标准库与平台能力优先。动手前 `codegraph context <任务主题>` 圈定相关符号与调用链；改共享符号前 `codegraph impact <符号>` 评估影响面，`codegraph affected` 找应回归的测试。按类型再加载对应 skill：

- bug 修复 → `diagnosing-bugs`（或 `systematic-debugging`）
- 新功能/增强 → `spec-driven-development`
- 有回归约束 → `test-driven-development`
- 文档/中文文案改动 → `tech-doc-style-chinese`

完成标准：变更通过所加载 skill 自身的验证要求（复现/测试/计划核对），而非"代码写完了"。

## 4. 审查

加载 `code-review`。Spec 轴按形态取：issue 流水线用原始 issue，PR 评审模式用评审意见——意见即规格。Standards 轴先读目标仓库自己的规范文档（AGENTS.md、TESTING.md、CONTRIBUTING 等），以它们为准。

完成标准：两轴均通过，或缺陷已修复并复验——受影响测试加全量门禁，修复只动了文案也一样。

## 5. 回写

- 走了本地流：`gh-issue-sync push`，标签、里程碑、关闭状态一并推回。
- 直接操作：MCP `issue_write` 关闭 + `add_issue_comment` 附证据（测试结果、PR 链接）。
- 需交付代码：`pr` 写正文，`finishing-a-development-branch` 收尾。
- 推送后跟进 CI：转红的修订先读日志定位、修复并复验，再回帖跟进；不在红状态上晾着，也不删跑 CI 的提交。

回写文本（评论、PR 正文）一律以当前账号的身份视角写：贡献者对维护者，第一人称立场——外发内容挂在这个账号名下，立场与口气属于账号本人，不是 AI 汇报工作。向维护者自己的行文学：短句直说，对着函数与行号点名，证据给具体数字；写「修了什么」时交代问题来源，旧有的写明旧有。

成稿校对按文本取：中文评论过 `tech-doc-style-chinese`；回帖变长或语气拿不准时过 `shuorenhua`（或 `humanizer-zh`）；PR 评审回帖按 `anti-defensive-writing` 的发布会原则组织——结论和最强事实在前，证据集中给，回复范围就停在评审意见问的事上。

完成标准：GitHub 上 issue 状态已更新且评论带证据链接。

分发（含 MCP transport 映射与内容清单核对）：读 [MCP 分发](references/mcp-distribution.md)。
