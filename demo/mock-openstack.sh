# Sourced only while recording demo/demo.tape.
#
# Fakes the network-touching leaf calls (the real `openstack` binary and
# `ssh`) so the recording is fast, deterministic, and never depends on a
# real OpenStack backend. Every other command in the demo (openv, opwho,
# opls, ops-ssh's fzf picker + IP-priority logic, opcheck's own if/else)
# is the plugin's real, unmodified code.

openstack() {
    case "$*" in
        "server list --format json")
            echo '[
                {"Name":"web-01","Status":"ACTIVE","Networks":"internal=10.0.0.15, external=203.0.113.42"},
                {"Name":"web-02","Status":"ACTIVE","Networks":"internal=10.0.0.16, external=203.0.113.43"},
                {"Name":"db-01","Status":"SHUTOFF","Networks":"internal=10.0.0.20"}
            ]'
            ;;
        "token issue")
            return 0
            ;;
        *)
            command openstack "$@"
            ;;
    esac
}

ssh() {
    echo "🔗 (demo) connected to ${@: -1}"
}
