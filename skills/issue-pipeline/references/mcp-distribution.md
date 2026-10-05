# MCP 分发（ext-skills）

何时读：要把本技能经 MCP 分发（`io.modelcontextprotocol/skills` 扩展），或核对分发就绪状态时。跑流水线不需要读本文件。

## 就绪状态

ext-skills 只定义传输绑定（`skills/list`、`skills/get`、`skill://` 资源、SHA-256 清单）；技能格式完全委托 AgentSkills 核心规范。作者侧核对结果：

| 规范要求 | 本技能 |
|---|---|
| SKILL.md 在根目录，含 name + description | ✓ |
| name 与目录名一致（URI 末段即 name） | ✓ `skill://issue-pipeline/SKILL.md` |
| 核心格式验证 | ✓ `uvx --from skills-ref agentskills validate` 通过 |
| 相对引用一层深、按技能根解析 | ✓ 引用均位于 `references/` 一层 |
| 无嵌套 SKILL.md（嵌套技能需独立同意） | ✓ 无 |
| metadata 不占用 `io.modelcontextprotocol/` 前缀 | ✓ |
| 不使用 allowed-tools（MCP 侧默认被忽略） | ✓ 未使用 |
| 限额：≤512 文件、合计 ≤16 MiB | ✓ 个位数文件、KB 级（`scripts/check.sh` 复核） |

## 内容清单（Skill entry 的 resources）

按 ext-skills 的 SkillResource 形状（uri + digest + size）。摘要随正文变动，硬编码基线必然过期，核对用可复现方法：

**方法一（推荐）**：任一实现 ext-skills 的服务端分发本技能目录，官方 MCP Inspector 验证（`SKILLS_DIR` 指向含本技能的目录）：

```sh
npx -y @modelcontextprotocol/inspector --cli node <server.mjs> --protocol-era modern \
  -e SKILLS_DIR=<skills-dir> --method skills/list --verify
```

退出码 0 = 三套检查（SEP-2640 一致性、摘要、frontmatter）全过。

**方法二（无服务端）**：直接算摘要：

```powershell
$dir = '<你的技能目录>\issue-pipeline'
Get-ChildItem -LiteralPath $dir -Recurse -File | ForEach-Object {
  $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
  $hex = -join ([System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes) | ForEach-Object ToString x2)
  '{0}  sha256:{1}  {2}B' -f "skill://issue-pipeline/$($_.FullName.Substring($dir.Length+1).Replace('\','/'))", $hex, $bytes.Length
}
```

正文改动后旧摘要即失效：宿主侧会把内容变更当作需要重新批准的变化，这是规范行为，不是故障。

## 服务端实现要点

搭服务时按规范（https://github.com/modelcontextprotocol/ext-skills 的 specification/stable/skills.mdx）：能力协商声明 `io.modelcontextprotocol/skills`；实现 `skills/list` 与 `skills/get`；frontmatter 逐字段原样透传；`resources` 清单必须完整（含 SKILL.md 自身）；目录读取是可选的 `directoryRead`。安全基线：消费侧把技能内容当不可信输入；摘要不是信任锚；用户批准绑定到 resources 集合，集合一变批准即撤销。
