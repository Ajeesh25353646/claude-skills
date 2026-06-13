# Claude Code Skills

A growing collection of [Claude Code](https://claude.codes/) skills I've built and open-sourced. Each skill lives in its own directory and can be installed individually.

## Skills

| Skill | Description |
|-------|-------------|
| [**ai-audit**](ai-audit/) | Detect and report AI fingerprints / slop in projects: copy tells, design patterns, and code habits that AI models default to. |
| [**free-image-generation**](free-image-generation/) | Generate images for free using multiple AI providers. Supports Cloudflare Workers AI (57 img/day free), HuggingFace Inference (83 img/month free), and Pollinations.ai (unlimited, no key required) with automatic tiered fallback. |

---

## Installing a Skill

### Via Claude Code Plugin Marketplace (recommended)

In a Claude Code session, run:

```
/plugin marketplace add Ajeesh25353646/claude-skills
/plugin install ai-audit@claude-skills
/plugin install free-image-generation@claude-skills
```

This gives you auto-updates. Skills are namespaced as `/{plugin-name}:{skill-name}`.

### Manual (symlink)

Clone the repo, then symlink the skill:

```bash
git clone https://github.com/Ajeesh25353646/claude-skills.git

# Symlink a skill
ln -sf $(pwd)/claude-skills/ai-audit ~/.claude/skills/ai-audit
ln -sf $(pwd)/claude-skills/free-image-generation ~/.claude/skills/free-image-generation
```

Once symlinked, invoke it as `/<skill-name>` across any Claude Code session.

## License

MIT
