# Claude Code Skills

A growing collection of [Claude Code](https://claude.codes/) skills I've built and open-sourced. Each skill lives in its own directory and can be installed individually.

## Skills

| Skill | Description |
|-------|-------------|
| [**ai-audit**](ai-audit/) | Detect and report AI fingerprints / slop in projects — copy tells, design patterns, and code habits that AI models default to. |

*More skills coming soon.*

---

## Installing a Skill

Clone the repo or grab the skill directory you want, then symlink it into your Claude Code skills directory:

```bash
# Clone the repo
git clone https://github.com/<your-username>/<repo-name>.git

# Symlink a skill (e.g., ai-audit)
ln -sf $(pwd)/claude-skills/ai-audit ~/.claude/skills/ai-audit
```

Once symlinked, you can invoke the skill by name — e.g., `/ai-audit` — and it will be available across all your Claude Code sessions.

## License

MIT