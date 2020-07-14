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

```cleanup='true'```

### $pre_transaction
Set a shell script or any other command you may want to run in your terminal.



### $post_transaction

### $force_reboot
This forces the system to schedule a reboot after every script run. Can be set to `'true'` or `'false'`.

```force_reboot='false'```

### $disable_reboot
Disables reboots even if they are needed. Can be set to `'true'` or `'false'`.

```disable_reboot='false'```

### $reboot_time 
Reboot_time sets when a reboot will be scheduled if it is needed. By default a reboot will only be scheduled if the kernel has be upgraded, or if a running service unit requires a reboot to take effect.

Schedules a reboot one minute after completion.

```reboot_time=$(date --date='1 minute' +%H:%M)```

Set a spesific time. Will rollover to the next day if that time has already passed.

```reboot_time='00:00'```
