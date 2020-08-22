#!/usr/bin/env bash

# Remove Core Files and Dirs
rm -R /opt/auto-patcher
rm -R /etc/auto-patcher

# Disable and Remove Service Unit
systemctl stop auto-patcher.timer
systemctl disable auto-patcher.timer
rm /usr/lib/systemd/system/auto-patcher.service
rm /usr/lib/systemd/system/auto-patcher.timer

echo Finished Uninstalling Auto-Patcher!
