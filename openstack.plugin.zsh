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
# Pattern: op + resource + action (l=list, a=list --all-projects, s=show,
# c=create, d=delete, e=set, r=reboot, h=stop, t=start).
alias opsl='openstack server list'
alias opsla='openstack server list --all-projects'
alias opss='openstack server show'
alias opsc='openstack server create'
alias opsd='openstack server delete'
alias opse='openstack server set'
alias opsr='openstack server reboot'
alias opsh='openstack server stop'
alias opst='openstack server start'
alias opsg='openstack console log show'

# --- 2. Networking & Security Aliases (Neutron) ---
alias opnl='openstack network list'
alias opns='openstack network show'
alias opnc='openstack network create'
alias opnd='openstack network delete'
alias opne='openstack network set'

alias opsnl='openstack subnet list'
alias opsns='openstack subnet show'
alias opsnc='openstack subnet create'
alias opsnd='openstack subnet delete'
alias opsne='openstack subnet set'

alias oprtl='openstack router list'
alias oprts='openstack router show'
alias oprtc='openstack router create'
alias oprtd='openstack router delete'
alias oprte='openstack router set'

alias opfil='openstack floating ip list'
alias opfis='openstack floating ip show'
alias opfic='openstack floating ip create'
alias opfid='openstack floating ip delete'
alias opfie='openstack floating ip set'

alias opsgl='openstack security group list'
alias opsgs='openstack security group show'
alias opsgc='openstack security group create'
alias opsgd='openstack security group delete'
alias opsge='openstack security group set'

alias opsgrl='openstack security group rule list'
alias opsgrs='openstack security group rule show'
alias opsgrc='openstack security group rule create'
alias opsgrd='openstack security group rule delete'

alias oppl='openstack port list'
alias opps='openstack port show'
alias oppc='openstack port create'
alias oppd='openstack port delete'
alias oppe='openstack port set'

# --- 3. Storage & Image Aliases (Cinder, Swift, Glance) ---
alias opvl='openstack volume list'
alias opvla='openstack volume list --all-projects'
alias opvs='openstack volume show'
alias opvc='openstack volume create'
alias opvd='openstack volume delete'
alias opve='openstack volume set'

alias opvsl='openstack volume snapshot list'
alias opvss='openstack volume snapshot show'
alias opvsc='openstack volume snapshot create'
alias opvsd='openstack volume snapshot delete'
alias opvse='openstack volume snapshot set'

alias opil='openstack image list'
alias opis='openstack image show'
alias opic='openstack image create'
alias opid='openstack image delete'
alias opie='openstack image set'

# --- 4. Identity & Quota Aliases (Keystone) ---
alias opprl='openstack project list'
alias opprs='openstack project show'
alias opprc='openstack project create'
alias opprd='openstack project delete'
alias oppre='openstack project set'

alias opul='openstack user list'
alias opus='openstack user show'
alias opuc='openstack user create'
alias opud='openstack user delete'
alias opue='openstack user set'

alias oprol='openstack role list'
alias opros='openstack role show'
alias oproc='openstack role create'
alias oprod='openstack role delete'

alias optks='openstack token issue'

alias opfll='openstack flavor list'
alias opfls='openstack flavor show'
alias opflc='openstack flavor create'
alias opfld='openstack flavor delete'

alias opkpl='openstack keypair list'
alias opkps='openstack keypair show'
alias opkpc='openstack keypair create'
alias opkpd='openstack keypair delete'

alias oplims='openstack limits show --absolute'
alias opqs='openstack quota show'
alias opqe='openstack quota set'

# --- 5. Load Balancers & Kubernetes (Octavia & Magnum) ---
alias oplbl='openstack loadbalancer list'
alias oplbs='openstack loadbalancer show'
alias oplbc='openstack loadbalancer create'
alias oplbd='openstack loadbalancer delete'
alias oplbe='openstack loadbalancer set'

alias opk8sl='openstack coe cluster list'
alias opk8ss='openstack coe cluster show'
alias opk8sc='openstack coe cluster create'
alias opk8sd='openstack coe cluster delete'

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
    _ophelp_row "ops-ssh [user] [-i key] [-p port] [--insecure]" "Pick a VM via fzf and SSH into it"
    _ophelp_row "ops-console"                          "Pick a VM via fzf and open its VNC console"

    echo
    echo "${YELLOW}${BOLD}Aliases${RESET}"
    _ophelp_row "op" "openstack"

    echo
    echo "  ${MAGENTA}Compute (Nova)${RESET}"
    _ophelp_row "opsl"  "openstack server list"
    _ophelp_row "opsla" "openstack server list --all-projects"
    _ophelp_row "opss"  "openstack server show"
    _ophelp_row "opsc"  "openstack server create"
    _ophelp_row "opsd"  "openstack server delete"
    _ophelp_row "opse"  "openstack server set"
    _ophelp_row "opsr"  "openstack server reboot"
    _ophelp_row "opsh"  "openstack server stop"
    _ophelp_row "opst"  "openstack server start"
    _ophelp_row "opsg"  "openstack console log show"

    echo
    echo "  ${MAGENTA}Networking & Security (Neutron)${RESET}"
    _ophelp_row "opnl"   "openstack network list"
    _ophelp_row "opns"   "openstack network show"
    _ophelp_row "opnc"   "openstack network create"
    _ophelp_row "opnd"   "openstack network delete"
    _ophelp_row "opne"   "openstack network set"
    _ophelp_row "opsnl"  "openstack subnet list"
    _ophelp_row "opsns"  "openstack subnet show"
    _ophelp_row "opsnc"  "openstack subnet create"
    _ophelp_row "opsnd"  "openstack subnet delete"
    _ophelp_row "opsne"  "openstack subnet set"
    _ophelp_row "oprtl"  "openstack router list"
    _ophelp_row "oprts"  "openstack router show"
    _ophelp_row "oprtc"  "openstack router create"
    _ophelp_row "oprtd"  "openstack router delete"
    _ophelp_row "oprte"  "openstack router set"
    _ophelp_row "opfil"  "openstack floating ip list"
    _ophelp_row "opfis"  "openstack floating ip show"
    _ophelp_row "opfic"  "openstack floating ip create"
    _ophelp_row "opfid"  "openstack floating ip delete"
    _ophelp_row "opfie"  "openstack floating ip set"
    _ophelp_row "opsgl"  "openstack security group list"
    _ophelp_row "opsgs"  "openstack security group show"
    _ophelp_row "opsgc"  "openstack security group create"
    _ophelp_row "opsgd"  "openstack security group delete"
    _ophelp_row "opsge"  "openstack security group set"
    _ophelp_row "opsgrl" "openstack security group rule list"
    _ophelp_row "opsgrs" "openstack security group rule show"
    _ophelp_row "opsgrc" "openstack security group rule create"
    _ophelp_row "opsgrd" "openstack security group rule delete"
    _ophelp_row "oppl"   "openstack port list"
    _ophelp_row "opps"   "openstack port show"
    _ophelp_row "oppc"   "openstack port create"
    _ophelp_row "oppd"   "openstack port delete"
    _ophelp_row "oppe"   "openstack port set"

    echo
    echo "  ${MAGENTA}Storage & Images (Cinder / Glance)${RESET}"
    _ophelp_row "opvl"  "openstack volume list"
    _ophelp_row "opvla" "openstack volume list --all-projects"
    _ophelp_row "opvs"  "openstack volume show"
    _ophelp_row "opvc"  "openstack volume create"
    _ophelp_row "opvd"  "openstack volume delete"
    _ophelp_row "opve"  "openstack volume set"
    _ophelp_row "opvsl" "openstack volume snapshot list"
    _ophelp_row "opvss" "openstack volume snapshot show"
    _ophelp_row "opvsc" "openstack volume snapshot create"
    _ophelp_row "opvsd" "openstack volume snapshot delete"
    _ophelp_row "opvse" "openstack volume snapshot set"
    _ophelp_row "opil"  "openstack image list"
    _ophelp_row "opis"  "openstack image show"
    _ophelp_row "opic"  "openstack image create"
    _ophelp_row "opid"  "openstack image delete"
    _ophelp_row "opie"  "openstack image set"

    echo
    echo "  ${MAGENTA}Identity & Quotas (Keystone)${RESET}"
    _ophelp_row "opprl"  "openstack project list"
    _ophelp_row "opprs"  "openstack project show"
    _ophelp_row "opprc"  "openstack project create"
    _ophelp_row "opprd"  "openstack project delete"
    _ophelp_row "oppre"  "openstack project set"
    _ophelp_row "opul"   "openstack user list"
    _ophelp_row "opus"   "openstack user show"
    _ophelp_row "opuc"   "openstack user create"
    _ophelp_row "opud"   "openstack user delete"
    _ophelp_row "opue"   "openstack user set"
    _ophelp_row "oprol"  "openstack role list"
    _ophelp_row "opros"  "openstack role show"
    _ophelp_row "oproc"  "openstack role create"
    _ophelp_row "oprod"  "openstack role delete"
    _ophelp_row "optks"  "openstack token issue"
    _ophelp_row "opfll"  "openstack flavor list"
    _ophelp_row "opfls"  "openstack flavor show"
    _ophelp_row "opflc"  "openstack flavor create"
    _ophelp_row "opfld"  "openstack flavor delete"
    _ophelp_row "opkpl"  "openstack keypair list"
    _ophelp_row "opkps"  "openstack keypair show"
    _ophelp_row "opkpc"  "openstack keypair create"
    _ophelp_row "opkpd"  "openstack keypair delete"
    _ophelp_row "oplims" "openstack limits show --absolute"
    _ophelp_row "opqs"   "openstack quota show"
    _ophelp_row "opqe"   "openstack quota set"

    echo
    echo "  ${MAGENTA}Load Balancers & Kubernetes (Octavia & Magnum)${RESET}"
    _ophelp_row "oplbl"  "openstack loadbalancer list"
    _ophelp_row "oplbs"  "openstack loadbalancer show"
    _ophelp_row "oplbc"  "openstack loadbalancer create"
    _ophelp_row "oplbd"  "openstack loadbalancer delete"
    _ophelp_row "oplbe"  "openstack loadbalancer set"
    _ophelp_row "opk8sl" "openstack coe cluster list"
    _ophelp_row "opk8ss" "openstack coe cluster show"
    _ophelp_row "opk8sc" "openstack coe cluster create"
    _ophelp_row "opk8sd" "openstack coe cluster delete"

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
        local exists
        exists=$(python3 "$_openstack_plugin_helper" check-key "$target_cloud" 2>/dev/null)
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
    # shellcheck disable=SC2034,SC2207
    # zsh-only: `clouds` is consumed by the zsh builtin `_describe` (not a
    # direct reference shellcheck can see), and zsh's `arr=($(...))` splits
    # on IFS in array-assignment context by default, unlike bash — the
    # mapfile/read -a suggestion doesn't apply here.
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
# Usage: ops-ssh [user] [-i identity_file] [-p port] [--insecure]
ops-ssh() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    local ssh_user="ubuntu"
    local identity_file=""
    local port=""
    local insecure=0
    local -a ssh_opts=()

    while (( $# )); do
        case "$1" in
            -i)
                identity_file="$2"
                shift 2
                ;;
            -p)
                port="$2"
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
        local target_ip
        target_ip=$(echo "$selected" | awk -F'|' '{print $3}' | xargs)
        if [[ "$target_ip" != "No-IP" && -n "$target_ip" ]]; then
            if [[ -n "$identity_file" ]]; then
                ssh_opts+=(-i "$identity_file" -o IdentitiesOnly=yes)
            fi
            [[ -n "$port" ]] && ssh_opts+=(-p "$port")
            if (( insecure )); then
                echo "⚠️  --insecure: skipping SSH host key verification (fine for ephemeral cloud VMs, risky elsewhere)."
                ssh_opts+=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)
            fi
            echo "🚀 Connecting to ${ssh_user}@${target_ip}${port:+:$port}..."
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
        local server_name
        server_name=$(echo "$selected" | awk -F'|' '{print $1}' | xargs)
        echo "🌐 Fetching VNC console URL for ${server_name}..."
        local console_url
        console_url=$(openstack console url show "$server_name" -f value -c url 2>/dev/null)
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
