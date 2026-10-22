# power-off

Powers off the machine once a long-running task is done, on Linux, macOS, Windows and WSL. It only runs when you
explicitly ask ("power off after finishing", "shut down when done"); the agent never decides to do it on its own.

It is an [Agent Skill](https://agentskills.io) (a `SKILL.md` plus two small scripts), so it works in Claude Code,
Cursor and any other agent that loads skills.

## How it works

1. **Trigger check**: only your own message in the conversation counts as a request.
2. **Finish first**: the work is completed (a failed task is retried once, then it powers off anyway) and the report
   written to a file, since the session dies at shutdown.
3. **Safety check**: it asks first on remote machines (SSH), when other users are logged in, and on WSL (where the
   command powers off the Windows host).
4. **Shutdown**: `scripts/power-off.sh` (or `power-off.ps1`) detects the OS, waits 5 seconds (so the agent can finish its reply) and runs the graceful command. No force flags.

| OS | Command |
|---|---|
| Linux | `systemctl poweroff` |
| macOS | `osascript -e 'tell app "System Events" to shut down'` |
| Windows | `shutdown /s /t 0` |
| WSL | `shutdown.exe /s /t 0` |

Try it safely with `sh skills/power-off/scripts/power-off.sh --dry-run`.

## Install

### Any agent: the `skills` CLI

```bash
npx skills add illescasDaniel/power-off
```

It asks which agents to install for and whether to install into the current project or globally. Non-interactive:
`npx skills add illescasDaniel/power-off -a claude-code -y`, plus `-g` for global.

### By hand

Copy the `skills/power-off` folder into your agent's skills directory.

| | Project (shared with your team) | All your projects |
|---|---|---|
| Claude Code | `.claude/skills/power-off/` | `~/.claude/skills/power-off/` |
| Cursor | `.cursor/skills/power-off/` | `~/.cursor/skills/power-off/` |

## Contributing

Issues and pull requests are welcome. The skill is deliberately short: if a change makes `SKILL.md` longer, it should
earn it.

## License

MIT, see [LICENSE](LICENSE).
