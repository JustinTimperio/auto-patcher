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
Cleans orhpaned packages and old cached package versions.

Can be set to `'true'` or `'false'`:\
`cleanup='true'`

### $pre_transaction
Trigger an event before auto-patcher runs any upgrades or maintenance.

Run a custom script:\
`pre_transaction='$(./home/user/custom.sh')`

Run a command directly:\
`pre_transaction=$(systemctl stop someunit.service anotherunit.service)`

### $post_transaction
Trigger an event after auto-patcher runs an upgrade but before a reboot is scheduled.

Run a custom script:\
`post_transaction='$(./home/user/custom.sh')`

Run a command directly:\
`post_transaction=$(systemctl start someunit.service anotherunit.service)`

### $force_reboot
This forces the system to schedule a reboot after every script completion.

Can be set to `'true'` or `'false'`:\
`force_reboot='false'`

### $disable_reboot
Disables reboots even if they are needed.

Can be set to `'true'` or `'false'`:\
`disable_reboot='false'`

### $reboot_time 
Reboot_time sets when a reboot will be scheduled if it is needed. By default a reboot will only be scheduled if the kernel has be upgraded, or if a running service unit requires a reboot to take effect.

Schedules a reboot one minute after completion:\
`reboot_time=$(date --date='1 minute' +%H:%M)`

Set a spesific time for a reboot to occur if it is needed:\
`reboot_time='00:00'`
