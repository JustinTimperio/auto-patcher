# Generic Auto-Patcher
![Codacy grade](https://img.shields.io/codacy/grade/ea8a661eab1f4f64960491c1f0dc6836?label=Codacy%20Grade&style=for-the-badge)
![GitHub](https://img.shields.io/github/license/justintimperio/auto-patcher?style=for-the-badge)\
A shell script and systemd service that automatically runs package upgrades, cleans orphaned and cached packages, schedules system reboots, and integrates custom pre and post transaction scripts.

## Supported Distro's
- Debian
- Ubuntu
- Centos
- Fedora
- Arch
- Manjaro

------------

### Install Auto-Patcher
`curl https://raw.githubusercontent.com/JustinTimperio/auto-patcher/master/install.sh | sudo bash`

### Uninstall Auto-Patcher
`sudo /opt/auto-patcher/remove.sh`

------------

## Using /etc/auto-patcher/config

### Cleanup
Cleans orhpaned packages and old cached package versions.

Can be set to `'true'` or `'false'`:\
`cleanup='true'`

### Pre_Transaction
Trigger an event before auto-patcher runs any upgrades or maintenance.

Run a custom script:\
`pre_transaction='$(./home/user/custom.sh')`

Run a command directly:\
`pre_transaction=$(systemctl stop someunit.service anotherunit.service)`

### Post_Transaction
Trigger an event after auto-patcher runs an upgrade but before a reboot is scheduled.

Run a custom script:\
`post_transaction='$(./home/user/custom.sh')`

Run a command directly:\
`post_transaction=$(systemctl start someunit.service anotherunit.service)`

### Force_Reboot
This forces the system to schedule a reboot after every script completion.

Can be set to `'true'` or `'false'`:\
`force_reboot='false'`

### Disable_Reboot
Disables reboots even if they are needed.

Can be set to `'true'` or `'false'`:\
`disable_reboot='false'`

### Reboot_Time 
Reboot_time sets when a reboot will be scheduled if it is needed. By default a reboot will only be scheduled if the kernel has be upgraded, or if a running service unit requires a reboot to take effect.

Schedules a reboot one minute after completion:\
`reboot_time=$(date --date='1 minute' +%H:%M)`

Set a spesific time for a reboot to occur if it is needed:\
`reboot_time='00:00'`
