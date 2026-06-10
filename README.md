# Claude Code Skills

A growing collection of [Claude Code](https://claude.codes/) skills I've built and open-sourced. Each skill lives in its own directory and can be installed individually.

## Skills

| Skill | Description |
|-------|-------------|
| [**ai-audit**](ai-audit/) | Detect and report AI fingerprints / slop in projects: copy tells, design patterns, and code habits that AI models default to. |

*More skills coming soon.*

---

## Installing a Skill

### Via Claude Code Plugin Marketplace (recommended)

In a Claude Code session, run:

```
/plugin marketplace add Ajeesh25353646/claude-skills
/plugin install ai-audit@claude-skills
```

This gives you auto-updates. Skills are namespaced as `/ai-audit:ai-audit`.

### Manual (symlink)

Clone the repo, then symlink the skill:

```bash
git clone https://github.com/Ajeesh25353646/claude-skills.git

# Symlink a skill
ln -sf $(pwd)/claude-skills/ai-audit ~/.claude/skills/ai-audit
```

Once symlinked, invoke it as `/ai-audit` across any Claude Code session.

## License

MIT