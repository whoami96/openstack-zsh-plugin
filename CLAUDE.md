# CLAUDE.md

Context for Claude Code (or any AI assistant) working on this repo.

## What this is

An Oh My Zsh plugin for OpenStack CLI workflows: cloud switching via
`fzf`, venv auto-activation, SSH/console VM helpers, an auth health
check, and ~25 short aliases for `openstack` subcommands. A personal
project (built for the author's own daily workflow, then open-sourced),
MIT licensed.

## Architecture

- `openstack.plugin.zsh` — every alias and zsh function (`openv`,
  `opwho`, `opcheck`, `ops-ssh`, `ops-console`, `ophelp`, `opexit`,
  `opls`, `op_prompt_info`). This is the file Oh My Zsh sources.
- `op-helper.py` — the only thing that touches `clouds.yaml`/YAML
  parsing. Invoked as `python3 op-helper.py <subcommand> [arg]`, with
  subcommands `list-keys`, `check-key`, `preview`, `who`, `list-table`.
  **Never interpolate a shell variable into a `python3 -c "..."`
  string** — pass it via `sys.argv` instead. An early version of `openv`
  did this for a cloud-name argument and it was a real code-injection
  bug; the current dispatch-by-argv design in `op-helper.py` is the fix,
  keep it that way.
- `demo/` — VHS recording assets behind the README GIF. `clouds.yaml`
  and `mock-openstack.sh` in there are fake/throwaway, safe to edit or
  regenerate; `demo.tape` scripts the recording. Important gotcha:
  VHS's shell does **not** source `~/.zshrc`/Oh My Zsh, so the tape
  explicitly runs `source openstack.plugin.zsh` before anything else —
  don't remove that or the recording will just show "command not
  found" for every plugin command. Re-render with
  `vhs demo/demo.tape` from the repo root.

## Conventions / decisions worth knowing before changing things

- Aliases are intentionally static, not data-driven. The repo is small
  enough that a shared alias→description table wasn't worth the
  refactor (deliberate choice, revisit only if the alias list grows a
  lot). Consequence: adding or renaming an alias means updating it in
  **three** places — the `alias` line itself, `ophelp()`, and
  `README.md`.
- `op-helper.py` caches the parsed `clouds.yaml` at
  `${XDG_CACHE_HOME:-~/.cache}/openstack-zsh-plugin/clouds_cache.json`,
  keyed by the paths and mtimes of `clouds.yaml` and `secure.yaml` (both are
  merged, `secure.yaml` wins per field, like openstacksdk). It's written with `0600` perms in a
  `0700` dir because `clouds.yaml` can contain plaintext passwords —
  don't loosen that when touching the cache code.
- The dependency check at the top of the `.zsh` file only warns about a
  missing `openstack` CLI if `~/.config/openstack/.venv/bin/activate`
  is *also* missing. Checking `command -v openstack` alone false-
  positives on the normal workflow, where `openstack` only appears on
  `PATH` after `openv` activates the venv — this shipped once and had
  to be walked back after it fired on every new shell.
- `ops-ssh`/`ops-console` check the **exit code** of
  `openstack server list`, not just whether the output was empty, so a
  broken CLI/expired auth gives a different message than a genuinely
  empty project.
- `ops-ssh -i <file>` also sets `-o IdentitiesOnly=yes`, and `-p <port>`
  is a real flag (not just cosmetic) — a missing `-p` previously caused
  silent hangs for anyone whose sshd isn't on port 22, since a filtered
  port drops the SYN instead of refusing it.

## Testing without a real OpenStack backend

There's no test suite. The pattern used throughout this project's
history is to override `openstack`, `ssh`, and `fzf` as shell functions
inline in a throwaway `zsh -c "..."` invocation, to dry-run plugin logic
deterministically without touching a real cloud, e.g.:

    zsh -c '
        source openstack.plugin.zsh
        OS_CLOUD=test-cloud
        openstack() { echo "[{\"Name\":\"vm1\",\"Status\":\"ACTIVE\",\"Networks\":\"external=203.0.113.42\"}]"; return 0; }
        fzf() { cat | head -1; }
        ops-ssh
    '

`demo/mock-openstack.sh` is a reusable version of the same idea, used
for the VHS recording.

Sanity checks to run before committing:

    zsh -n openstack.plugin.zsh
    python3 -c "import ast; ast.parse(open('op-helper.py').read())"

## Do not commit

- Anything derived from a real `clouds.yaml` — this repo is public.
  Fixtures for demos/tests must stay obviously fake (see
  `demo/clouds.yaml` for the pattern: `.invalid` TLD, RFC 5737 IPs, a
  joke password).
