# ==============================================================================
# OpenStack Zsh Plugin (openstack.plugin.zsh)
# Author: Pawel Owczarczyk
# Repository: https://github.com/whoami96/openstack-zsh-plugin
# ==============================================================================

alias op='openstack'

# --- Resolve helper script path ---
_op_helper="${0:A:h}/op-helper.py"

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
op_prompt_info() {
    if [[ -n "$OS_CLOUD" ]]; then
        echo "☁️  [${OS_CLOUD}]"
    fi
}

# --- 7. Activate OpenStack VirtualEnv & Select Cloud ---
openv() {
    local OS_VENV="$HOME/.config/openstack/.venv"
    local target_cloud="$1"
    local selected_cloud=""

    # 1. Select cloud FIRST (via argument or interactively through fzf)
    if [[ -n "$target_cloud" ]]; then
        # Safe check using sys.argv[2] in helper script (prevents code injection)
        local exists=$(python3 "$_op_helper" check-key "$target_cloud" 2>/dev/null)
        if [[ "$exists" == "True" ]]; then
            selected_cloud="$target_cloud"
        else
            echo "⚠️  Cloud '$target_cloud' not found in clouds configuration."
            return 1
        fi
    else
        selected_cloud=$(python3 "$_op_helper" list-keys 2>/dev/null | \
            fzf --height 60% --reverse --cycle --border rounded \
                --prompt="󱇩 Select OpenStack Cloud: " \
                --preview "python3 '$_op_helper' preview {}" \
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
    clouds=($(python3 "$_op_helper" list-keys 2>/dev/null))
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

    python3 "$_op_helper" who "$OS_CLOUD" 2>/dev/null
}
alias opstatus='opwho'

# --- List all configured OpenStack clouds ---
opls() {
    python3 "$_op_helper" list-table 2>/dev/null
}
alias opclouds='opls'

# --- Interactive SSH into OpenStack VMs via fzf ---
ops-ssh() {
    if [[ -z "$OS_CLOUD" ]]; then
        echo "⚠️  No active OS_CLOUD set. Run: openv"
        return 1
    fi

    local ssh_user="${1:-ubuntu}"
    echo "󰢹 Fetching server list from OpenStack ($OS_CLOUD)..."

    local raw_json
    raw_json=$(openstack server list --format json 2>/dev/null)

    if [[ -z "$raw_json" || "$raw_json" == "[]" ]]; then
        echo "⚠️  No servers found in project or failed to fetch server list."
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
            echo "🚀 Connecting to ${ssh_user}@${target_ip}..."
            ssh "${ssh_user}@${target_ip}"
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

    if [[ -z "$raw_json" || "$raw_json" == "[]" ]]; then
        echo "⚠️  No servers found in project."
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
