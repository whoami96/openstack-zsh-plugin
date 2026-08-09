#!/usr/bin/env python3
import sys, os, yaml

cloud_name = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("CLOUD", "")
cfg_path = os.path.expanduser("~/.config/openstack/clouds.yaml")

CYAN = "\033[1;36m"
YELLOW = "\033[1;33m"
GREEN = "\033[1;32m"
BLUE = "\033[1;34m"
MAGENTA = "\033[1;35m"
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"

if not cloud_name:
    sys.exit(0)

try:
    with open(cfg_path) as f:
        data = yaml.safe_load(f)
    cloud = data.get("clouds", {}).get(cloud_name, {})
    auth = cloud.get("auth", {})

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
except Exception as e:
    print(f"Error loading preview: {e}")
