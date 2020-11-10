#! /usr/bin/env sh

# Clone Repo
rm -rf /opt/auto-patcher
git clone https://github.com/JustinTimperio/auto-patcher.git /opt/auto-patcher

# Add Config to /etc
mkdir -p /etc/auto-patcher
cp /opt/auto-patcher/config /etc/auto-patcher/config

if [ "$(uname)" = 'FreeBSD' ]; then
  croncmd="/opt/auto-patcher/auto-patcher.sh"
  cronjob="0 0 * * 1 $croncmd"
  ( crontab -l | grep -v -F "$croncmd" || : ; echo "$cronjob" ) | crontab -

else
  # Add Service Unit Files
  mkdir -p /usr/lib/systemd/system
  cp /opt/auto-patcher/daemon/auto-patcher.service /usr/lib/systemd/system/auto-patcher.service
  cp /opt/auto-patcher/daemon/auto-patcher.timer /usr/lib/systemd/system/auto-patcher.timer

  # Enable Service Unit
  systemctl daemon-reload
  systemctl enable --now auto-patcher.timer
  systemctl start auto-patcher.timer
fi

echo Finished Installing Auto-Patcher!
