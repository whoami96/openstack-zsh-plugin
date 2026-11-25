# ☁️ openstack-zsh-plugin

An interactive, feature-rich **Oh My Zsh** plugin for managing **OpenStack** CLI environments, cloud contexts, virtualenv auto-activation, and shortcuts.

![Zsh](https://img.shields.io/badge/zsh-%23000000.svg?style=for-the-badge&logo=zsh&logoColor=white)
![OpenStack](https://img.shields.io/badge/OpenStack-%23E00000.svg?style=for-the-badge&logo=openstack&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

---

## 🎬 Demo

![Demo of openstack-zsh-plugin: ophelp, openv cloud picker with fzf preview, opwho, ops-ssh, opcheck](demo/demo.gif)

*Recorded with [VHS](https://github.com/charmbracelet/vhs) against fake demo data — see `demo/` to regenerate it (`vhs demo/demo.tape`).*

---

## ✨ Features

- ⚡ **Interactive Cloud Selector (`openv`)**: Browse and activate OpenStack clouds defined in `~/.config/openstack/clouds.yaml` (plus `secure.yaml`, merged like openstacksdk does) via `fzf` with live ANSI card preview.
- 🔒 **No Secrets in Preview**: The `fzf` preview card only ever reads and prints non-sensitive fields (auth URL, project, username, region) — it never touches `password` or secret fields from `clouds.yaml`.
- 🎯 **Tab Completion**: Auto-completes `openv <cloud_name>` directly in your shell.
- 🚀 **Interactive SSH (`ops-ssh`)**: Select OpenStack VMs interactively with `fzf` and SSH straight into them.
- 🌐 **VNC Console Launcher (`ops-console`)**: Generate VNC console URLs and open them directly in your browser.
- 📊 **Status & Summary (`opwho`, `opls`)**: Display active cloud connection status or list all configured clouds in a clean ASCII table.
- 🛠️ **Comprehensive Aliases**: 100 short aliases for Nova, Neutron, Cinder, Keystone, Glance, Octavia, and Magnum, following a consistent `op` + resource + action pattern.

---

## ✅ Requirements

- **zsh** with [Oh My Zsh](https://ohmyz.sh/)
- **python3** with the [`PyYAML`](https://pypi.org/project/PyYAML/) package installed (`pip install pyyaml`)
- **[fzf](https://github.com/junegunn/fzf)** for the interactive selectors (`openv`, `ops-ssh`, `ops-console`)
- **[python-openstackclient](https://docs.openstack.org/python-openstackclient/)** (the `openstack` CLI) configured with a `clouds.yaml` (default: `~/.config/openstack/clouds.yaml`, or set `OS_CLIENT_CONFIG_FILE`); an optional `secure.yaml` next to it (or `OS_CLIENT_SECURE_FILE`) is merged in, same-name clouds overridden field by field
- **ssh** on `PATH` for `ops-ssh`
- A **[Nerd Font](https://www.nerdfonts.com/)** in your terminal — several icons in the output (`󱇩`, `󰢹`, `󱄊`, ...) are Nerd Font glyphs and render as boxes/question marks without one

The plugin checks for `python3`, `PyYAML`, and `fzf` on load and prints a warning if any are missing.

### Setting up the `openstack` venv

`openv` expects a virtualenv at `~/.config/openstack/.venv` and auto-activates/deactivates
it as you switch clouds (see `opexit`) — it doesn't create one for you. Here's the setup
used to build/test this plugin, with [`uv`](https://docs.astral.sh/uv/):

```bash
mkdir -p ~/.config/openstack
cd ~/.config/openstack
uv venv .venv --python 3.12
source .venv/bin/activate

uv pip install \
  python-openstackclient \
  python-neutronclient \
  python-octaviaclient \
  python-barbicanclient \
  python-ironicclient \
  python-designateclient \
  python-troveclient \
  python-magnumclient \
  osc-placement \
  gnocchiclient \
  aodhclient \
  -c https://releases.openstack.org/constraints/upper/2025.1 \
  --python .venv/bin/python
```

Notes:

- Only `python-openstackclient` is actually required by this plugin — the rest are extra
  per-service CLIs (Neutron, Octavia, Barbican, Ironic, Designate, Trove, Magnum,
  Placement, Gnocchi, Aodh); add or drop whichever match the services your cloud exposes.
- The `-c .../constraints/upper/2025.1` pins dependency versions to a known-good set for
  that OpenStack release — swap `2025.1` for the release your cloud/clients target.
- No `uv`? A plain `python3 -m venv .venv` followed by `pip install ...` (same package
  list, no `-c`/`--python` flags) works just as well — `openv` only cares that
  `~/.config/openstack/.venv/bin/activate` exists.

---

## 📦 Installation

### Oh My Zsh

Clone this repository into your Oh My Zsh custom plugins directory:

```bash
git clone https://github.com/whoami96/openstack-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/openstack
```

Then add `openstack` to your plugins list in `~/.zshrc`:

```zsh
plugins=(
  git
  ...
  openstack
)
```

Reload Zsh:

```bash
source ~/.zshrc
```

---

## 🚀 Usage & Commands

### Cloud Management

| Command | Description |
| :--- | :--- |
| **`openv [cloud]`** | Select and activate an OpenStack cloud (interactive with `fzf` or direct) |
| **`opexit`** / `opoff` / `opclear` | Deactivate virtualenv and clear `OS_CLOUD` environment variable |
| **`opwho`** / `opstatus` | Display current active OpenStack cloud, user, project, and auth URL |
| **`opls`** / `opclouds` | List all configured OpenStack clouds in `clouds.yaml` |
| **`opcheck`** | Quick health check — verifies the active cloud's token/credentials are still valid |
| **`ophelp`** / `openv --help` / `openv -h` | Print a categorized cheatsheet of every command and alias below |
| **`op_prompt_info`** | Prints `☁️  [cloud]` for the active cloud — add `$(op_prompt_info)` to your `PROMPT`/`RPROMPT` for a prompt segment |

### Interactive VM Helpers

| Command | Description |
| :--- | :--- |
| **`ops-ssh [user] [-i identity_file] [-p port] [--insecure]`** | Pick an OpenStack VM via `fzf` and connect via SSH (default user: `ubuntu`). `-i` selects a specific keypair file (implies `IdentitiesOnly=yes`); `-p` sets a non-default SSH port; `--insecure` skips host key verification — handy for ephemeral cloud VMs whose floating IP gets reused |
| **`ops-console`** | Pick an OpenStack VM via `fzf` and open its Horizon VNC console in browser |

### Shortcuts & Aliases

- `op` $\rightarrow$ `openstack`

Naming pattern: `op` + resource + action, where the action letter is
`l`=list, `a`=list --all-projects, `s`=show, `c`=create, `d`=delete,
`e`=set, `r`=reboot, `h`=stop, `t`=start. Not every resource supports
every action (e.g. roles/flavors/keypairs have no `set`, security group
rules have no `set`, quota only has show/set) — only real `openstack`
subcommands are aliased.

#### Compute (Nova)
- `opsl` $\rightarrow$ `openstack server list`
- `opsla` $\rightarrow$ `openstack server list --all-projects`
- `opss` $\rightarrow$ `openstack server show`
- `opsc` $\rightarrow$ `openstack server create`
- `opsd` $\rightarrow$ `openstack server delete`
- `opse` $\rightarrow$ `openstack server set`
- `opsr` $\rightarrow$ `openstack server reboot`
- `opsh` $\rightarrow$ `openstack server stop`
- `opst` $\rightarrow$ `openstack server start`
- `opsg` $\rightarrow$ `openstack console log show`

#### Networking & Security (Neutron)
- `opnl` $\rightarrow$ `openstack network list`
- `opns` $\rightarrow$ `openstack network show`
- `opnc` $\rightarrow$ `openstack network create`
- `opnd` $\rightarrow$ `openstack network delete`
- `opne` $\rightarrow$ `openstack network set`
- `opsnl` $\rightarrow$ `openstack subnet list`
- `opsns` $\rightarrow$ `openstack subnet show`
- `opsnc` $\rightarrow$ `openstack subnet create`
- `opsnd` $\rightarrow$ `openstack subnet delete`
- `opsne` $\rightarrow$ `openstack subnet set`
- `oprtl` $\rightarrow$ `openstack router list`
- `oprts` $\rightarrow$ `openstack router show`
- `oprtc` $\rightarrow$ `openstack router create`
- `oprtd` $\rightarrow$ `openstack router delete`
- `oprte` $\rightarrow$ `openstack router set`
- `opfil` $\rightarrow$ `openstack floating ip list`
- `opfis` $\rightarrow$ `openstack floating ip show`
- `opfic` $\rightarrow$ `openstack floating ip create`
- `opfid` $\rightarrow$ `openstack floating ip delete`
- `opfie` $\rightarrow$ `openstack floating ip set`
- `opsgl` $\rightarrow$ `openstack security group list`
- `opsgs` $\rightarrow$ `openstack security group show`
- `opsgc` $\rightarrow$ `openstack security group create`
- `opsgd` $\rightarrow$ `openstack security group delete`
- `opsge` $\rightarrow$ `openstack security group set`
- `opsgrl` $\rightarrow$ `openstack security group rule list`
- `opsgrs` $\rightarrow$ `openstack security group rule show`
- `opsgrc` $\rightarrow$ `openstack security group rule create`
- `opsgrd` $\rightarrow$ `openstack security group rule delete`
- `oppl` $\rightarrow$ `openstack port list`
- `opps` $\rightarrow$ `openstack port show`
- `oppc` $\rightarrow$ `openstack port create`
- `oppd` $\rightarrow$ `openstack port delete`
- `oppe` $\rightarrow$ `openstack port set`

#### Storage & Images (Cinder / Glance)
- `opvl` $\rightarrow$ `openstack volume list`
- `opvla` $\rightarrow$ `openstack volume list --all-projects`
- `opvs` $\rightarrow$ `openstack volume show`
- `opvc` $\rightarrow$ `openstack volume create`
- `opvd` $\rightarrow$ `openstack volume delete`
- `opve` $\rightarrow$ `openstack volume set`
- `opvsl` $\rightarrow$ `openstack volume snapshot list`
- `opvss` $\rightarrow$ `openstack volume snapshot show`
- `opvsc` $\rightarrow$ `openstack volume snapshot create`
- `opvsd` $\rightarrow$ `openstack volume snapshot delete`
- `opvse` $\rightarrow$ `openstack volume snapshot set`
- `opil` $\rightarrow$ `openstack image list`
- `opis` $\rightarrow$ `openstack image show`
- `opic` $\rightarrow$ `openstack image create`
- `opid` $\rightarrow$ `openstack image delete`
- `opie` $\rightarrow$ `openstack image set`

#### Identity & Quotas (Keystone)
- `opprl` $\rightarrow$ `openstack project list`
- `opprs` $\rightarrow$ `openstack project show`
- `opprc` $\rightarrow$ `openstack project create`
- `opprd` $\rightarrow$ `openstack project delete`
- `oppre` $\rightarrow$ `openstack project set`
- `opul` $\rightarrow$ `openstack user list`
- `opus` $\rightarrow$ `openstack user show`
- `opuc` $\rightarrow$ `openstack user create`
- `opud` $\rightarrow$ `openstack user delete`
- `opue` $\rightarrow$ `openstack user set`
- `oprol` $\rightarrow$ `openstack role list`
- `opros` $\rightarrow$ `openstack role show`
- `oproc` $\rightarrow$ `openstack role create`
- `oprod` $\rightarrow$ `openstack role delete`
- `optks` $\rightarrow$ `openstack token issue`
- `opfll` $\rightarrow$ `openstack flavor list`
- `opfls` $\rightarrow$ `openstack flavor show`
- `opflc` $\rightarrow$ `openstack flavor create`
- `opfld` $\rightarrow$ `openstack flavor delete`
- `opkpl` $\rightarrow$ `openstack keypair list`
- `opkps` $\rightarrow$ `openstack keypair show`
- `opkpc` $\rightarrow$ `openstack keypair create`
- `opkpd` $\rightarrow$ `openstack keypair delete`
- `oplims` $\rightarrow$ `openstack limits show --absolute`
- `opqs` $\rightarrow$ `openstack quota show`
- `opqe` $\rightarrow$ `openstack quota set`

#### Load Balancers & Kubernetes (Octavia & Magnum)
- `oplbl` $\rightarrow$ `openstack loadbalancer list`
- `oplbs` $\rightarrow$ `openstack loadbalancer show`
- `oplbc` $\rightarrow$ `openstack loadbalancer create`
- `oplbd` $\rightarrow$ `openstack loadbalancer delete`
- `oplbe` $\rightarrow$ `openstack loadbalancer set`
- `opk8sl` $\rightarrow$ `openstack coe cluster list`
- `opk8ss` $\rightarrow$ `openstack coe cluster show`
- `opk8sc` $\rightarrow$ `openstack coe cluster create`
- `opk8sd` $\rightarrow$ `openstack coe cluster delete`

---

## 📜 License

Distributed under the [MIT License](LICENSE). Copyright © 2026 Paweł Owczarczyk.
