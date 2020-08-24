#!/usr/bin/env bash

# Clone Repo
git clone https://github.com/JustinTimperio/auto-patcher.git /opt/auto-patcher

# Add Config to /etc
mkdir -p /etc/auto-patcher
cp /opt/auto-patcher/config /etc/auto-patcher/config

# Add Service Unit Files
cp /opt/auto-patcher/daemon/auto-patcher.service /usr/lib/systemd/user/auto-patcher.service
cp /opt/auto-patcher/daemon/auto-patcher.timer /usr/lib/systemd/user/auto-patcher.timer

# Enable Service Unit
systemctl daemon-reload
systemctl enable --now auto-patcher.timer
systemctl start auto-patcher.timer

echo Finished Installing Auto-Patcher!
