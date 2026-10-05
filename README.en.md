<sub>🌐 <a href="README.md">中文</a> · <b>English</b></sub>

<div align="center">

# issue-pipeline

> *"An issue list won't shrink itself — but it can become a pipeline."*

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-issue--pipeline-blueviolet)](skills/issue-pipeline/SKILL.md)
[![skills.sh](https://skills.sh/b/qikairo7/issue-pipeline)](https://skills.sh/qikairo7/issue-pipeline)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**A five-stage pipeline that takes a repo's GitHub issues / PRs from pull, through triage, implementation and review, all the way to write-back and close — peers cover single stages; this one paves the whole road, including a PR review-feedback mode.**

[See it work](#example) · [Install](#quick-start) · [Triggers](#triggers) · [How it differs](#how-it-differs-from-peers) · [Safety bounds](#safety-bounds)

</div>

---

<p align="center">
  <img src="assets/demo-install.png" width="100%" alt="Real install & self-check run">
</p>

<sub>A real run, not a mock: public `npx skills add` install → `git clone` → `bash scripts/check.sh`, six checks green.</sub>

---

## The problem it solves

Here's the thing: you take over an open-source repo. Thirty-odd open issues, reviewer feedback sitting in PRs, CI quietly turning red three days later. Every time you process one, you re-invent the flow — what to look at first? Whose bug is it if it won't reproduce? Do I take every review comment? How do I reply without sounding like a bot?

The usual approach is improvising each time: it works, but quality depends on mood and discipline never accumulates. Peer skills cover one segment each — triage, or review, or auto-fix — and you stitch the segments together by hand.

This skill paves the whole road: **pull & sync → triage & verify → claim & implement → dual-axis review → write back to GitHub**, five stages each with a completion bar; plus a **PR review-feedback mode** peers don't have — the maintainer's comments ARE the spec: implement item by item, verify on two axes, reply in the account owner's own voice.

## Example

A real run (de-identified at the author's request; numbers from the run log): [Working a PR review, full replay](skills/issue-pipeline/examples/review-feedback-run.md)

```text
Input   "process <PR with review feedback> <PR link>"
Action  identity check (PR author) → re-run claimed evidence (17 tests green)
        → apply both review items (drop 5 old tests, add 2 new pins)
        → dual-axis review catches a misleading error message, fixed
Output  full suite 1893 tests green · typecheck clean · 9 CI checks green
        → PR title/body narrowed to match scope → item-by-item reply with evidence
```

## Quick start

Prerequisite: `gh` logged in (zero API keys; everything goes through gh / GitHub MCP).

```bash
npx skills add qikairo7/issue-pipeline
```

gh CLI users:

```bash
gh skill install qikairo7/issue-pipeline
```

Then say to your agent:

```text
Process https://github.com/<owner>/<repo>/pull/<number> with issue-pipeline
```

Expected: the agent first determines the target form and your identity (PR author / maintainer / third party), reports that verdict, then enters the matching stage of the pipeline.

## Triggers

- "Process this PR with issue-pipeline"
- "Help me digest <repo>'s open issues"
- "Work the review feedback on this PR"
- "Claim and fix issue #123"
- "Pull this repo's issues locally, push the fixes back"
- "Triage this repo's bug reports"

Not triggered by: read-only questions (checking a version, reading one issue) — that doesn't need a pipeline.

## How it differs from peers

| Dimension | Peers | **issue-pipeline** |
|---|---|---|
| Coverage | One segment: triage ([github-triage](https://www.skills.sh/trailofbits/skills/github-triage), [triage](https://www.skills.sh/mattpocock/skills/triage)) or review (Tessl PR skills) or auto-fix ([github-issue-resolver](https://clawhub.ai/ashwinhegde19/skills/github-issue-resolver)) | Pull → triage → implement → review → write-back, with a completion bar between stages |
| Review feedback | Absent | **Comments are the spec**: item by item, untouched what wasn't named, single revision commit, PR body narrowed to match |
| Reply voice | Not encoded | First person as the account owner, evidence in numbers, defect origins stated |
| Review | Single view or none | Dual axis: Spec (issue or review comments) + Standards (the target repo's own docs) |
| Failure modes | Varies | CI-red follow-up, outbound-denied stop, can't-reproduce → needs-info, missing deps degrade instead of halting |

## Safety bounds

- Outbound writes (comments, closes, pushes) require your per-session authorization; on refusal it stops and reports — no path-hopping retries.
- No force-push — rollbacks use revert, keeping history auditable.
- Never merges, tags or releases on the maintainer's behalf; asks first even with permission.
- An unreproducible bug stops at `needs-info` with actionable questions — no guess-driven fixes.
- No gh login → report; never degrades to web scraping.

## Layout

```text
├── README.md                        ← this file
├── LICENSE                          ← MIT
├── .claude-plugin/marketplace.json  ← Claude Code plugin marketplace channel
├── scripts/check.sh                 ← one-command self check after clone
└── skills/issue-pipeline/
    ├── SKILL.md                     ← the five-stage pipeline (+ PR-mode routing)
    ├── references/
    │   ├── pr-review-mode.md        ← PR review-feedback stage mapping
    │   └── mcp-distribution.md      ← MCP (ext-skills) distribution checklist
    ├── examples/
    │   └── review-feedback-run.md   ← de-identified real run
    └── test-prompts.json            ← 4 acceptance prompts with kill conditions
```

## Verification

```bash
bash scripts/check.sh
```

Covers: skills-ref spec validation (when available), referenced-file existence, ext-skills distribution limits, test-prompt validity. Acceptance prompts live in [test-prompts.json](skills/issue-pipeline/test-prompts.json) — each with a killCondition, so one run tells you whether it installed right.

## Acknowledgements

- Skill format & progressive disclosure: the [Agent Skills specification](https://agentskills.io/specification)
- MCP distribution checks: [modelcontextprotocol/ext-skills](https://github.com/modelcontextprotocol/ext-skills)
- Repo layout reference: [anthropics/skills](https://github.com/anthropics/skills)

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md): one facet per commit, `bash scripts/check.sh` green before you push.

## License

This project is licensed under the [MIT License](./LICENSE).
