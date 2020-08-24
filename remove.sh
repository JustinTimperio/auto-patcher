#!/usr/bin/env bash

# Remove Core Files and Dirs
rm -R /opt/auto-patcher
rm -R /etc/auto-patcher
rm /var/log/auto-patcher.log

# Disable and Remove Service Unit
systemctl stop auto-patcher.timer
systemctl disable auto-patcher.timer
rm /usr/lib/systemd/user/auto-patcher.service
rm /usr/lib/systemd/user/auto-patcher.timer

echo Finished Uninstalling Auto-Patcher!
