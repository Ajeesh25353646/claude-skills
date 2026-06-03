# Claude Code Skills

A growing collection of [Claude Code](https://claude.codes/) skills I've built and open-sourced. Each skill lives in its own directory and can be installed individually.

## Skills

| Skill | Description |
|-------|-------------|
| [**ai-audit**](ai-audit/) | Detect and report AI fingerprints / slop in projects: copy tells, design patterns, and code habits that AI models default to. |

*More skills coming soon.*

---

## Installing a Skill

Clone the repo, then symlink a skill into your Claude Code skills directory:

```bash
git clone https://github.com/<your-username>/<repo-name>.git

# Symlink a skill
ln -sf $(pwd)/claude-skills/ai-audit ~/.claude/skills/ai-audit
```

Once symlinked, invoke the skill by name via `/ai-audit` across any Claude Code session.

## License

MIT