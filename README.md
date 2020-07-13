# Generic Auto-Patcher
A shell script and systemd service that automatically runs package upgrades, cleans orphaned and cached packages, schedules system reboots, and integrates custom pre and post transaction scripts.

## Supported Distro's
- Debian
- Ubuntu
- Centos
- Fedora
- Arch
- Manjaro

## Using config.sh Options

### $cleanup
Cleans orhpaned packages and old cached package versions. Can be set to `'true'` or `'false'`.
`cleanup='true'`

### $force_reboot
This forces the system to schedule a reboot after every script run. Can be set to `'true'` or `'false'`.
`force_reboot='false'`

### $disable_reboot
Disables reboots even if they are needed. Can be set to `'true'` or `'false'`.
`disable_reboot='false'`

### $reboot_time 
This schedules a reboot one min after completion.
`reboot_time=$(date --date='1 minute' +%H:%M)`
This can also be set to a spesific time.
`reboot_time='00:00'`
