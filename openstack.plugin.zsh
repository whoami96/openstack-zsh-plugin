# ==============================================================================
# OpenStack Zsh Plugin (openstack.plugin.zsh)
# Author: Pawel Owczarczyk
# Repository: https://github.com/whoami96/openstack-zsh-plugin
# ==============================================================================

alias op='openstack'

# --- Resolve helper script path ---
_openstack_plugin_helper="${0:A:h}/op-helper.py"

# --- Dependency checks (run once when the plugin loads) ---
if ! command -v python3 >/dev/null 2>&1; then
    print -u2 "⚠️  openstack-zsh-plugin: python3 not found — most commands will not work."
elif ! python3 -c "import yaml" >/dev/null 2>&1; then
    print -u2 "⚠️  openstack-zsh-plugin: PyYAML not installed — run 'pip install pyyaml' (in the venv used by this plugin)."
fi
if ! command -v fzf >/dev/null 2>&1; then
    print -u2 "⚠️  openstack-zsh-plugin: fzf not found — interactive selectors (openv, ops-ssh, ops-console) will not work."
fi
if ! command -v openstack >/dev/null 2>&1 && [[ ! -f "$HOME/.config/openstack/.venv/bin/activate" ]]; then
    print -u2 "⚠️  openstack-zsh-plugin: 'openstack' CLI not found — install python-openstackclient, or set up the venv (openv) that is expected to provide it."
fi

# --- 1. Compute & Server Aliases (Nova) ---
alias ops='openstack server list'
alias opsa='openstack server list --all-projects'
alias opss='openstack server show'
alias opsr='openstack server reboot'
alias opsh='openstack server stop'
alias opst='openstack server start'
alias opsdel='openstack server delete'
alias oplog='openstack console log show'

# --- 2. Networking & Security Aliases (Neutron) ---
alias opnet='openstack network list'
alias opsub='openstack subnet list'
alias oprtr='openstack router list'
alias opfip='openstack floating ip list'
alias opip='openstack floating ip list'
alias opsec='openstack security group list'
alias opsecr='openstack security group rule list'
alias opport='openstack port list'

# --- 3. Storage & Image Aliases (Cinder, Swift, Glance) ---
alias opvol='openstack volume list'
alias opvola='openstack volume list --all-projects'
alias opsnap='openstack volume snapshot list'
alias opimg='openstack image list'

# --- 4. Identity & Quota Aliases (Keystone) ---
alias opproj='openstack project list'
alias opuser='openstack user list'
alias oprole='openstack role list'
alias optoken='openstack token issue'
alias opfl='openstack flavor list'
alias opkey='openstack keypair list'
alias oplim='openstack limits show --absolute'

# --- 5. Load Balancers & Kubernetes (Octavia & Magnum) ---
alias oplb='openstack loadbalancer list'
alias opk8s='openstack coe cluster list'
alias opcoe='openstack coe cluster list'

# --- 6. Prompt Helper for Zsh themes ---
# Usage: add $(op_prompt_info) to your PROMPT/RPROMPT to show the active cloud.
op_prompt_info() {
    if [[ -n "$OS_CLOUD" ]]; then
        echo "☁️  [${OS_CLOUD}]"
    fi
}

# --- 7. Cheatsheet of commands & aliases (also: openv --help / openv -h) ---
_ophelp_row() {
    printf "  \033[1;32m%-38s\033[0m %s\n" "$1" "$2"
}

ophelp() {
    local CYAN=$'\033[1;36m' YELLOW=$'\033[1;33m' MAGENTA=$'\033[1;35m'
    local BOLD=$'\033[1m' DIM=$'\033[2m' RESET=$'\033[0m'

    echo "${CYAN}${BOLD}󱇩 openstack-zsh-plugin — command reference${RESET}"
    echo "${DIM}$(printf '─%.0s' {1..64})${RESET}"

    echo
    echo "${YELLOW}${BOLD}Cloud Management${RESET}"
    _ophelp_row "openv [cloud]"             "Select/activate an OpenStack cloud (fzf or direct)"
    _ophelp_row "openv --help"              "Show this help"
    _ophelp_row "opexit / opoff / opclear"  "Deactivate venv and clear OS_CLOUD"
    _ophelp_row "opwho / opstatus"          "Show active cloud, user, project, auth URL"
    _ophelp_row "opls / opclouds"           "List all configured clouds"
    _ophelp_row "opcheck"                   "Verify the active cloud's token/credentials"

    echo
    echo "${YELLOW}${BOLD}Prompt Integration${RESET}"
    _ophelp_row "op_prompt_info" "Prints '☁️  [cloud]' — add \$(op_prompt_info) to PROMPT/RPROMPT"

    echo
    echo "${YELLOW}${BOLD}Interactive VM Helpers${RESET}"
    _ophelp_row "ops-ssh [user] [-i key] [--insecure]" "Pick a VM via fzf and SSH into it"
    _ophelp_row "ops-console"                          "Pick a VM via fzf and open its VNC console"

    echo
    echo "${YELLOW}${BOLD}Aliases${RESET}"
    _ophelp_row "op" "openstack"

    echo
    echo "  ${MAGENTA}Compute (Nova)${RESET}"
    _ophelp_row "ops"    "openstack server list"
    _ophelp_row "opsa"   "openstack server list --all-projects"
    _ophelp_row "opss"   "openstack server show"
    _ophelp_row "opsr"   "openstack server reboot"
    _ophelp_row "opsh"   "openstack server stop"
    _ophelp_row "opst"   "openstack server start"
    _ophelp_row "opsdel" "openstack server delete"
    _ophelp_row "oplog"  "openstack console log show"

    echo
    echo "  ${MAGENTA}Networking & Security (Neutron)${RESET}"
    _ophelp_row "opnet"       "openstack network list"
    _ophelp_row "opsub"       "openstack subnet list"
    _ophelp_row "oprtr"       "openstack router list"
    _ophelp_row "opfip, opip" "openstack floating ip list"
    _ophelp_row "opsec"       "openstack security group list"
    _ophelp_row "opsecr"      "openstack security group rule list"
    _ophelp_row "opport"      "openstack port list"

    echo
    echo "  ${MAGENTA}Storage & Images (Cinder / Glance)${RESET}"
    _ophelp_row "opvol"  "openstack volume list"
    _ophelp_row "opvola" "openstack volume list --all-projects"
    _ophelp_row "opsnap" "openstack volume snapshot list"
    _ophelp_row "opimg"  "openstack image list"

    echo
    echo "  ${MAGENTA}Identity & Quotas (Keystone)${RESET}"
    _ophelp_row "opproj"  "openstack project list"
    _ophelp_row "opuser"  "openstack user list"
    _ophelp_row "oprole"  "openstack role list"
    _ophelp_row "optoken" "openstack token issue"
    _ophelp_row "opfl"    "openstack flavor list"
    _ophelp_row "opkey"   "openstack keypair list"
    _ophelp_row "oplim"   "openstack limits show --absolute"

    echo
    echo "  ${MAGENTA}Load Balancers & Kubernetes (Octavia & Magnum)${RESET}"
    _ophelp_row "oplb"         "openstack loadbalancer list"
    _ophelp_row "opk8s, opcoe" "openstack coe cluster list"

    echo
    echo "${DIM}Full docs: README.md${RESET}"
}

# --- 8. Activate OpenStack VirtualEnv & Select Cloud ---
openv() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        ophelp
        return 0
    fi

    local OS_VENV="$HOME/.config/openstack/.venv"
    local target_cloud="$1"
    local selected_cloud=""

    # 1. Select cloud FIRST (via argument or interactively through fzf)
    if [[ -n "$target_cloud" ]]; then
        # Safe check using sys.argv[2] in helper script (prevents code injection)
        local exists=$(python3 "$_openstack_plugin_helper" check-key "$target_cloud" 2>/dev/null)
        if [[ "$exists" == "True" ]]; then
            selected_cloud="$target_cloud"
        else
            echo "⚠️  Cloud '$target_cloud' not found in clouds configuration."
            return 1
        fi
    else
        selected_cloud=$(python3 "$_openstack_plugin_helper" list-keys 2>/dev/null | \
            fzf --height 60% --reverse --cycle --border rounded \
                --prompt="󱇩 Select OpenStack Cloud: " \
                --preview "python3 '$_openstack_plugin_helper' preview {}" \
                --preview-window=right:55%)
    fi

    # 2. If selection was canceled (Ctrl-C / ESC), exit cleanly without activating venv
    if [[ -z "$selected_cloud" ]]; then
        echo "🚫 Canceled."
        return 0
    fi

    # 3. Deactivate any existing non-openstack venv first to prevent PATH pollution
    if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" != "$OS_VENV" ]]; then
        if command -v deactivate >/dev/null 2>&1; then
            deactivate
        fi
    fi

    # 4. Activate OS_VENV ONLY AFTER successful cloud selection
    if [[ "$VIRTUAL_ENV" != "$OS_VENV" ]]; then
        if [[ -f "$OS_VENV/bin/activate" ]]; then
            export VIRTUAL_ENV_DISABLE_PROMPT=1
            source "$OS_VENV/bin/activate"
        else
            echo "󱄊 Error: Virtual environment not found at $OS_VENV. Run: uv venv $OS_VENV --python 3.12"
            return 1
        fi
    fi

    # 5. Set OS_CLOUD environment variable
    export OS_CLOUD="$selected_cloud"
    echo "󱇩 Active OpenStack Cloud: $OS_CLOUD"
}

# --- Zsh autocompletion for openv <TAB> ---
_openv_complete() {
    local -a clouds
    clouds=($(python3 "$_openstack_plugin_helper" list-keys 2>/dev/null))
    _describe 'OpenStack Cloud' clouds
}
compdef _openv_complete openv 2>/dev/null

# --- Deactivate OpenStack Environment ---
opexit() {
    if command -v deactivate >/dev/null 2>&1; then
        deactivate
    fi
    unset OS_CLOUD
    echo "󱇩 OpenStack environment cleared."
}
alias opoff='opexit'
alias opclear='opexit'

# --- Show active OpenStack session info ---
opwho() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    echo "󱇩 Active Cloud  : $OS_CLOUD"
    echo "🐍 Active Venv   : ${VIRTUAL_ENV:-None}"
    echo ""

    python3 "$_openstack_plugin_helper" who "$OS_CLOUD" 2>/dev/null
}
alias opstatus='opwho'

# --- Quick auth/connectivity health check for the active cloud ---
opcheck() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    echo "󱇩 Checking OpenStack authentication for '$OS_CLOUD'..."
    if openstack token issue >/dev/null 2>&1; then
        echo "✅ Token is valid — authenticated as cloud '$OS_CLOUD'."
    else
        echo "❌ Authentication failed for '$OS_CLOUD' — token may be expired or credentials invalid."
        echo "   Try: openv $OS_CLOUD"
        return 1
    fi
}

# --- List all configured OpenStack clouds ---
opls() {
    python3 "$_openstack_plugin_helper" list-table 2>/dev/null
}
alias opclouds='opls'

# --- Interactive SSH into OpenStack VMs via fzf ---
# Usage: ops-ssh [user] [-i identity_file] [--insecure]
ops-ssh() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    local ssh_user="ubuntu"
    local identity_file=""
    local insecure=0
    local -a ssh_opts=()

    while (( $# )); do
        case "$1" in
            -i)
                identity_file="$2"
                shift 2
                ;;
            --insecure)
                insecure=1
                shift
                ;;
            -*)
                echo "⚠️  Unknown option: $1"
                return 1
                ;;
            *)
                ssh_user="$1"
                shift
                ;;
        esac
    done

    echo "󰢹 Fetching server list from OpenStack ($OS_CLOUD)..."

    local raw_json
    raw_json=$(openstack server list --format json 2>/dev/null)
    local os_exit=$?

    if (( os_exit != 0 )); then
        echo "⚠️  Failed to run 'openstack server list' (exit $os_exit). Is the CLI installed and are you authenticated? Try: opcheck"
        return 1
    fi

    if [[ -z "$raw_json" || "$raw_json" == "[]" ]]; then
        echo "⚠️  No servers found in this project."
        return 1
    fi

    local selected
    selected=$(python3 -c "
import json, sys, re
try:
    data = json.loads(sys.stdin.read())
    for s in data:
        name = s.get('Name', 'N/A')
        status = s.get('Status', 'N/A')
        nets = str(s.get('Networks', ''))
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', nets)
        # Prioritize public/floating IP over internal RFC1918 IPs
        best_ip = 'No-IP'
        if ips:
            public_ips = [ip for ip in ips if not (ip.startswith('10.') or ip.startswith('192.168.') or (ip.startswith('172.') and 16 <= int(ip.split('.')[1]) <= 31))]
            best_ip = public_ips[0] if public_ips else ips[-1]
        print(f'{name:32s} | {status:10s} | {best_ip}')
except Exception as e:
    pass
" <<< "$raw_json" | fzf --height 50% --reverse --cycle --border rounded --prompt="󰢹 Select Server to SSH (${ssh_user}@...): ")

    if [[ -n "$selected" ]]; then
        local target_ip=$(echo "$selected" | awk -F'|' '{print $3}' | xargs)
        if [[ "$target_ip" != "No-IP" && -n "$target_ip" ]]; then
            [[ -n "$identity_file" ]] && ssh_opts+=(-i "$identity_file")
            if (( insecure )); then
                echo "⚠️  --insecure: skipping SSH host key verification (fine for ephemeral cloud VMs, risky elsewhere)."
                ssh_opts+=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
            fi
            echo "🚀 Connecting to ${ssh_user}@${target_ip}..."
            ssh "${ssh_opts[@]}" "${ssh_user}@${target_ip}"
        else
            echo "⚠️  Selected server has no IP address."
        fi
    else
        echo "🚫 Canceled."
    fi
}

# --- Interactive Console URL generator for OpenStack VMs via fzf ---
ops-console() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    echo "󰢹 Fetching server list from OpenStack ($OS_CLOUD)..."

    local raw_json
    raw_json=$(openstack server list --format json 2>/dev/null)
    local os_exit=$?

    if (( os_exit != 0 )); then
        echo "⚠️  Failed to run 'openstack server list' (exit $os_exit). Is the CLI installed and are you authenticated? Try: opcheck"
        return 1
    fi

    if [[ -z "$raw_json" || "$raw_json" == "[]" ]]; then
        echo "⚠️  No servers found in this project."
        return 1
    fi

    local selected
    selected=$(python3 -c "
import json, sys
try:
    data = json.loads(sys.stdin.read())
    for s in data:
        name = s.get('Name', 'N/A')
        status = s.get('Status', 'N/A')
        print(f'{name:35s} | {status}')
except Exception as e:
    pass
" <<< "$raw_json" | fzf --height 50% --reverse --cycle --border rounded --prompt="󰢹 Select Server for Console URL: ")

    if [[ -n "$selected" ]]; then
        local server_name=$(echo "$selected" | awk -F'|' '{print $1}' | xargs)
        echo "🌐 Fetching VNC console URL for ${server_name}..."
        local console_url=$(openstack console url show "$server_name" -f value -c url 2>/dev/null)
        if [[ -n "$console_url" ]]; then
            echo ""
            echo "🔗 Console URL: $console_url"
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$console_url" 2>/dev/null &
                echo "🚀 Opened console URL in browser."
            elif command -v open >/dev/null 2>&1; then
                open "$console_url" 2>/dev/null &
                echo "🚀 Opened console URL in browser."
            fi
        else
            echo "⚠️  Failed to generate console URL for $server_name."
        fi
    else
        echo "🚫 Canceled."
    fi
}
