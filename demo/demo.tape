# VHS tape for openstack-zsh-plugin — https://github.com/charmbracelet/vhs
#
# Install VHS:  https://github.com/charmbracelet/vhs#installation
#               (needs ttyd + ffmpeg + a Chromium/Chrome binary on PATH)
# Render:       cd openstack-zsh-plugin && vhs demo/demo.tape
# Output:       demo/demo.gif
#
# Uses a throwaway fake demo/clouds.yaml and mocks the network-touching
# `openstack`/`ssh` calls via demo/mock-openstack.sh, so recording this
# never depends on — or leaks anything about — a real cloud. Every other
# command (openv, opwho, opls, ophelp, ops-ssh's picker/IP logic,
# opcheck's own success/fail branching) is the plugin's real code.

Output demo/demo.gif

Require zsh
Require fzf
Require python3

Set Shell "zsh"
Set FontSize 18
Set Width 1400
Set Height 820
Set Padding 20
Set Theme "Dracula"
Set TypingSpeed 45ms

# --- Hidden setup: load the plugin + fake cloud config + mocked calls -----
# VHS's shell does not source ~/.zshrc/oh-my-zsh, so the plugin has to be
# sourced explicitly here (run vhs from the repo root for this path to work).
Hide
Type "source openstack.plugin.zsh"
Enter
Type "export OS_CLIENT_CONFIG_FILE=$PWD/demo/clouds.yaml"
Enter
Type "source demo/mock-openstack.sh"
Enter
Type "clear"
Enter
Show
# ----------------------------------------------------------------------------

Type "ophelp"
Enter
Sleep 3s

Type "clear"
Enter
Sleep 500ms

Type "openv"
Enter
Sleep 1s
Down
Sleep 600ms
Down
Sleep 600ms
Up
Sleep 600ms
Enter
Sleep 1.5s

Type "opwho"
Enter
Sleep 2s

Type "ops-ssh"
Enter
Sleep 1s
Down
Sleep 600ms
Enter
Sleep 1.5s

Type "opcheck"
Enter
Sleep 2.5s
