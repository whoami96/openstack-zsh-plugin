# ☁️ openstack-zsh-plugin

An interactive, feature-rich **Oh My Zsh** plugin for managing **OpenStack** CLI environments, cloud contexts, virtualenv auto-activation, and shortcuts.

![Zsh](https://img.shields.io/badge/zsh-%23000000.svg?style=for-the-badge&logo=zsh&logoColor=white)
![OpenStack](https://img.shields.io/badge/OpenStack-%23E00000.svg?style=for-the-badge&logo=openstack&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

---

## ✨ Features

- ⚡ **Interactive Cloud Selector (`openv`)**: Browse and activate OpenStack clouds defined in `~/.config/openstack/clouds.yaml` via `fzf` with live ANSI card preview.
- 🔒 **No Secrets in Preview**: The `fzf` preview card only ever reads and prints non-sensitive fields (auth URL, project, username, region) — it never touches `password` or secret fields from `clouds.yaml`.
- 🎯 **Tab Completion**: Auto-completes `openv <cloud_name>` directly in your shell.
- 🚀 **Interactive SSH (`ops-ssh`)**: Select OpenStack VMs interactively with `fzf` and SSH straight into them.
- 🌐 **VNC Console Launcher (`ops-console`)**: Generate VNC console URLs and open them directly in your browser.
- 📊 **Status & Summary (`opwho`, `opls`)**: Display active cloud connection status or list all configured clouds in a clean ASCII table.
- 🛠️ **Comprehensive Aliases**: Over 20+ short aliases for Nova, Neutron, Cinder, Keystone, Glance, Octavia, and Magnum.

---

## ✅ Requirements

- **zsh** with [Oh My Zsh](https://ohmyz.sh/)
- **python3** with the [`PyYAML`](https://pypi.org/project/PyYAML/) package installed (`pip install pyyaml`)
- **[fzf](https://github.com/junegunn/fzf)** for the interactive selectors (`openv`, `ops-ssh`, `ops-console`)
- **[python-openstackclient](https://docs.openstack.org/python-openstackclient/)** (the `openstack` CLI) configured with a `clouds.yaml` (default: `~/.config/openstack/clouds.yaml`, or set `OS_CLIENT_CONFIG_FILE`)
- **ssh** on `PATH` for `ops-ssh`
- A **[Nerd Font](https://www.nerdfonts.com/)** in your terminal — several icons in the output (`󱇩`, `󰢹`, `󱄊`, ...) are Nerd Font glyphs and render as boxes/question marks without one

The plugin checks for `python3`, `PyYAML`, and `fzf` on load and prints a warning if any are missing.

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

### Interactive VM Helpers

| Command | Description |
| :--- | :--- |
| **`ops-ssh [user] [-i identity_file] [--insecure]`** | Pick an OpenStack VM via `fzf` and connect via SSH (default user: `ubuntu`). `-i` selects a specific keypair file; `--insecure` skips host key verification — handy for ephemeral cloud VMs whose floating IP gets reused |
| **`ops-console`** | Pick an OpenStack VM via `fzf` and open its Horizon VNC console in browser |

### Shortcuts & Aliases

- `op` $\rightarrow$ `openstack`

#### Compute (Nova)
- `ops` $\rightarrow$ `openstack server list`
- `opsa` $\rightarrow$ `openstack server list --all-projects`
- `opss` $\rightarrow$ `openstack server show`
- `opsr` $\rightarrow$ `openstack server reboot`
- `opsh` $\rightarrow$ `openstack server stop`
- `opst` $\rightarrow$ `openstack server start`
- `opsdel` $\rightarrow$ `openstack server delete`
- `oplog` $\rightarrow$ `openstack console log show`

#### Networking & Security (Neutron)
- `opnet` $\rightarrow$ `openstack network list`
- `opsub` $\rightarrow$ `openstack subnet list`
- `oprtr` $\rightarrow$ `openstack router list`
- `opfip` / `opip` $\rightarrow$ `openstack floating ip list`
- `opsec` $\rightarrow$ `openstack security group list`
- `opsecr` $\rightarrow$ `openstack security group rule list`
- `opport` $\rightarrow$ `openstack port list`

#### Storage & Images (Cinder / Glance)
- `opvol` $\rightarrow$ `openstack volume list`
- `opvola` $\rightarrow$ `openstack volume list --all-projects`
- `opsnap` $\rightarrow$ `openstack volume snapshot list`
- `opimg` $\rightarrow$ `openstack image list`

#### Identity & Quotas (Keystone)
- `opproj` $\rightarrow$ `openstack project list`
- `opuser` $\rightarrow$ `openstack user list`
- `oprole` $\rightarrow$ `openstack role list`
- `optoken` $\rightarrow$ `openstack token issue`
- `opfl` $\rightarrow$ `openstack flavor list`
- `opkey` $\rightarrow$ `openstack keypair list`
- `oplim` $\rightarrow$ `openstack limits show --absolute`

#### Load Balancers & Kubernetes (Octavia & Magnum)
- `oplb` $\rightarrow$ `openstack loadbalancer list`
- `opk8s` / `opcoe` $\rightarrow$ `openstack coe cluster list`

---

## 📜 License

Distributed under the [MIT License](LICENSE). Copyright © 2026 Paweł Owczarczyk.
