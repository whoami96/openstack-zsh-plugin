# ==============================================================================
# OpenStack Zsh Plugin (openstack.plugin.zsh)
# Author: Pawel Owczarczyk
# Repository: https://github.com/whoami96/openstack-zsh-plugin
# ==============================================================================

alias op='openstack'

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
    local preview_script="${0:A:h}/preview.py"
    if [[ ! -f "$preview_script" ]]; then
        preview_script="$HOME/.config/openstack/preview.py"
    fi

    # 1. Select cloud FIRST (via argument or interactively through fzf)
    if [[ -n "$target_cloud" ]]; then
        local exists=$(python3 -c "import yaml, os; print('$target_cloud' in yaml.safe_load(open(os.path.expanduser('~/.config/openstack/clouds.yaml')))['clouds'])" 2>/dev/null)
        if [[ "$exists" == "True" ]]; then
            selected_cloud="$target_cloud"
        else
            echo "⚠️  Cloud '$target_cloud' not found in clouds.yaml."
            return 1
        fi
    else
        selected_cloud=$(python3 -c "import yaml, os; print('\n'.join(yaml.safe_load(open(os.path.expanduser('~/.config/openstack/clouds.yaml')))['clouds'].keys()))" 2>/dev/null | \
            fzf --height 60% --reverse --cycle --border rounded \
                --prompt="󱇩 Select OpenStack Cloud: " \
                --preview "python3 $preview_script {}" \
                --preview-window=right:55%)
    fi

    # 2. If selection was canceled (Ctrl-C / ESC), exit cleanly without activating venv
    if [[ -z "$selected_cloud" ]]; then
        echo "🚫 Canceled."
        return 0
    fi

    # 3. Activate venv ONLY AFTER successful cloud selection
    if [[ "$VIRTUAL_ENV" != "$OS_VENV" ]]; then
        if [[ -f "$OS_VENV/bin/activate" ]]; then
            export VIRTUAL_ENV_DISABLE_PROMPT=1
            source "$OS_VENV/bin/activate"
        else
            echo "󱄊 Error: Virtual environment not found at $OS_VENV. Run: uv venv $OS_VENV --python 3.12"
            return 1
        fi
    fi

    # 4. Set OS_CLOUD environment variable
    export OS_CLOUD="$selected_cloud"
    echo "󱇩 Active OpenStack Cloud: $OS_CLOUD"
}

# --- Zsh autocompletion for openv <TAB> ---
_openv_complete() {
    local -a clouds
    clouds=($(python3 -c "import yaml, os; print(' '.join(yaml.safe_load(open(os.path.expanduser('~/.config/openstack/clouds.yaml')))['clouds'].keys()))" 2>/dev/null))
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

    python3 -c "
import yaml, os
cloud_name = os.environ.get('OS_CLOUD')
cfg_path = os.path.expanduser('~/.config/openstack/clouds.yaml')
try:
    with open(cfg_path) as f:
        data = yaml.safe_load(f)
    cloud = data.get('clouds', {}).get(cloud_name, {})
    auth = cloud.get('auth', {})
    print(f'🌐 Auth URL : {auth.get(\"auth_url\", \"N/A\")}')
    print(f'📁 Project  : {auth.get(\"project_name\", auth.get(\"project_domain_name\", \"N/A\"))}')
    print(f'👤 User     : {auth.get(\"username\", \"AppCredential\")}')
    print(f'📍 Region   : {cloud.get(\"region_name\", \"N/A\")}')
except Exception as e:
    print(f'Error reading config: {e}')
"
}
alias opstatus='opwho'

# --- List all configured OpenStack clouds ---
opls() {
    echo "📋 Configured OpenStack environments (~/.config/openstack/clouds.yaml):"
    echo ""
    python3 -c "
import yaml, os
cfg_path = os.path.expanduser('~/.config/openstack/clouds.yaml')
with open(cfg_path) as f:
    data = yaml.safe_load(f)

clouds = data.get('clouds', {})
print(f'{\"CLOUD NAME\":32s} | {\"PROJECT / ID\":28s} | {\"USER\":20s} | {\"AUTH URL\":35s}')
print('-' * 125)
for name, cfg in clouds.items():
    auth = cfg.get('auth', {})
    proj = auth.get('project_name', auth.get('application_credential_id', 'N/A'))
    user = auth.get('username', 'AppCredential')
    url = auth.get('auth_url', 'N/A')
    print(f'{name:32s} | {proj:28s} | {user:20s} | {url:35s}')
"
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
        ip_str = ips[-1] if ips else 'No-IP'
        print(f'{name:32s} | {status:10s} | {ip_str}')
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
            fi
        else
            echo "⚠️  Failed to generate console URL for $server_name."
        fi
    else
        echo "🚫 Canceled."
    fi
}
