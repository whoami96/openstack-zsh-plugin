#!/usr/bin/env python3
# ==============================================================================
# OpenStack Zsh Plugin Helper Script (op-helper.py)
# Author: Pawel Owczarczyk
# Repository: https://github.com/whoami96/openstack-zsh-plugin
# ==============================================================================

import sys
import os
import yaml

def get_config_path():
    """Resolves OpenStack clouds.yaml path following standard precedence."""
    env_path = os.environ.get("OS_CLIENT_CONFIG_FILE")
    if env_path and os.path.isfile(env_path):
        return env_path
    
    candidates = [
        "./clouds.yaml",
        os.path.expanduser("~/.config/openstack/clouds.yaml"),
        "/etc/openstack/clouds.yaml"
    ]
    for path in candidates:
        if os.path.isfile(path):
            return path
    return os.path.expanduser("~/.config/openstack/clouds.yaml")

def load_clouds():
    """Loads and parses OpenStack clouds configuration safely."""
    path = get_config_path()
    if not os.path.isfile(path):
        return {}
    try:
        with open(path) as f:
            data = yaml.safe_load(f)
        return data.get("clouds", {})
    except Exception:
        return {}

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    target = sys.argv[2] if len(sys.argv) > 2 else ""

    clouds = load_clouds()

    if cmd == "list-keys":
        print("\n".join(clouds.keys()))

    elif cmd == "check-key":
        print("True" if target in clouds else "False")

    elif cmd == "preview":
        cloud_name = target or os.environ.get("CLOUD", "")
        if not cloud_name:
            sys.exit(0)
        
        cloud = clouds.get(cloud_name, {})
        auth = cloud.get("auth", {})

        CYAN = "\033[1;36m"; YELLOW = "\033[1;33m"; GREEN = "\033[1;32m"
        BLUE = "\033[1;34m"; MAGENTA = "\033[1;35m"; RESET = "\033[0m"
        BOLD = "\033[1m"; DIM = "\033[2m"

        auth_url = auth.get("auth_url", "N/A")
        project = auth.get("project_name", auth.get("project_domain_name", "N/A"))
        user = auth.get("username", "N/A")
        app_id = auth.get("application_credential_id", "")
        auth_type = cloud.get("auth_type", "password" if user != "N/A" else "v3applicationcredential")
        region = cloud.get("region_name", "N/A")
        version = cloud.get("identity_api_version", "3")
        interface = cloud.get("interface", "public")

        print(f"\n{CYAN}󱇩 OpenStack Cloud Details{RESET}")
        print(f"{DIM}{'─' * 46}{RESET}")
        print(f"{BOLD}🏷️  Name       :{RESET} {YELLOW}{cloud_name}{RESET}")
        print(f"{BOLD}🌐 Auth URL   :{RESET} {BLUE}{auth_url}{RESET}")
        if user != "N/A":
            print(f"{BOLD}👤 Username   :{RESET} {GREEN}{user}{RESET}")
        if project != "N/A":
            print(f"{BOLD}📁 Project    :{RESET} {GREEN}{project}{RESET}")
        if app_id:
            print(f"{BOLD}🔑 App Cred ID:{RESET} {GREEN}{app_id[:20]}...{RESET}")
        print(f"{BOLD}🔐 Auth Type  :{RESET} {MAGENTA}{auth_type}{RESET}")
        print(f"{BOLD}📍 Region     :{RESET} {CYAN}{region}{RESET}")
        print(f"{BOLD}🔖 API Version:{RESET} {interface} / v{version}")
        print(f"{DIM}{'─' * 46}{RESET}\n")

    elif cmd == "who":
        cloud_name = target or os.environ.get("OS_CLOUD", "")
        cloud = clouds.get(cloud_name, {})
        auth = cloud.get("auth", {})
        print(f"🌐 Auth URL : {auth.get('auth_url', 'N/A')}")
        print(f"📁 Project  : {auth.get('project_name', auth.get('project_domain_name', 'N/A'))}")
        print(f"👤 User     : {auth.get('username', 'AppCredential')}")
        print(f"📍 Region   : {cloud.get('region_name', 'N/A')}")

    elif cmd == "list-table":
        path = get_config_path()
        print(f"📋 Configured OpenStack environments ({path}):\n")
        print(f"{'CLOUD NAME':32s} | {'PROJECT / ID':28s} | {'USER':20s} | {'AUTH URL':35s}")
        print("-" * 125)
        for name, cfg in clouds.items():
            auth = cfg.get("auth", {})
            proj = auth.get("project_name", auth.get("application_credential_id", "N/A"))
            user = auth.get("username", "AppCredential")
            url = auth.get("auth_url", "N/A")
            print(f"{name:32s} | {proj:28s} | {user:20s} | {url:35s}")

if __name__ == "__main__":
    main()
