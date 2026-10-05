# 贡献指南

欢迎 issue 与 PR。这个仓库是一个 Agent Skill，改动前请先装一遍、跑一遍：

```bash
npx skills add qikairo7/issue-pipeline   # 装最新发布版
git clone https://github.com/qikairo7/issue-pipeline
bash scripts/check.sh                    # 仓库自检应全过
```

## 提 issue

- 先看 open issues 有无重复。
- 报缺陷时附上触发语句（test-prompts.json 里有现成格式）与预期行为。

## 提 PR

- 一次提交只改一个面（工作流、失败模式、示例各自独立提交），过 `bash scripts/check.sh` 再推。
- 动 SKILL.md 正文时，同步检查两个语言版本的 README 是否需要跟进。
- 提交信息说清为什么改，不只是改了什么。

## License

提交即表示同意以 [MIT License](./LICENSE) 授权。
