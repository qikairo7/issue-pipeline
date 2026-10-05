#!/usr/bin/env bash
# issue-pipeline 仓库自检：任何人 clone 后一条命令核对技能健康。
# 用法: bash scripts/check.sh   （在仓库根目录执行）
set -euo pipefail
cd "$(dirname "$0")/.."

SKILL="skills/issue-pipeline/SKILL.md"
pass() { echo "PASS $1"; }
fail() { echo "FAIL $1"; FAILED=1; }
FAILED=0

# 1. 官方规范校验（可用则用，不可用则退回基础检查）
if command -v uvx >/dev/null 2>&1; then
  uvx --from skills-ref agentskills validate "skills/issue-pipeline" && pass "skills-ref validate" || fail "skills-ref validate"
else
  head -1 "$SKILL" | grep -q '^---$' && pass "frontmatter delimiter" || fail "frontmatter delimiter"
  grep -q '^name: issue-pipeline$' "$SKILL" && pass "name field" || fail "name field"
  desc_len=$(awk '/^description: /{sub(/^description: /,""); print length($0)}' "$SKILL")
  [ "$desc_len" -gt 0 ] && [ "$desc_len" -le 1024 ] && pass "description length (${desc_len})" || fail "description length (${desc_len})"
fi

# 2. SKILL.md 内引用的仓库内文件必须真实存在
missing=0
while IFS= read -r ref; do
  target="skills/issue-pipeline/${ref#./}"
  [ -f "$target" ] && pass "reference exists: $ref" || { fail "reference missing: $ref"; missing=1; }
done < <(grep -oE '\]\((\./)?[a-zA-Z0-9_/.-]+\.md\)' "$SKILL" | sed -E 's/^\]\(//; s/\)$//')

# 3. ext-skills 分发限额：≤512 文件、合计 ≤16 MiB
file_count=$(find "skills/issue-pipeline" -type f | wc -l)
total_bytes=$(find "skills/issue-pipeline" -type f -print0 | xargs -0 stat -c %s | awk '{s+=$1} END {print s+0}')
[ "$file_count" -le 512 ] && pass "file count (${file_count}/512)" || fail "file count (${file_count}/512)"
[ "$total_bytes" -le 16777216 ] && pass "total bytes (${total_bytes}/16777216)" || fail "total bytes (${total_bytes}/16777216)"

# 4. 测试样例是合法 JSON 且至少 4 条
if command -v node >/dev/null 2>&1; then
  prompt_count=$(node -e "console.log(require('./skills/issue-pipeline/test-prompts.json').testPrompts.length)")
  [ "$prompt_count" -ge 4 ] 2>/dev/null \
    && pass "test-prompts.json (${prompt_count} prompts)" || fail "test-prompts.json invalid"
fi

echo "---"
[ "$FAILED" -eq 0 ] && echo "OK: all checks passed" || { echo "FAILED: see above"; exit 1; }
