#!/usr/bin/env bash

# Remove Core Files and Dirs
rm /opt/auto-patcher
rm /etc/auto-patcher

# Disable and Remove Service Unit
systemctl disable auto-patcher.timer
rm /usr/lib/systemd/system/auto-patcher.service
rm /usr/lib/systemd/system/auto-patcher.timer

echo Finished Uninstalling Auto-Patcher!
