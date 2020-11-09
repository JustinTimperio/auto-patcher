#! /usr/bin/env sh

# Remove Core Files and Dirs
rm -R /opt/auto-patcher
rm -R /etc/auto-patcher
rm /var/log/auto-patcher.log

if [ "$(uname)" = 'FreeBSD' ]; then
  echo 'This is NOT done yet'

else
  # Disable and Remove Service Unit
  systemctl stop auto-patcher.timer
  systemctl disable auto-patcher.timer
  rm /usr/lib/systemd/system/auto-patcher.service
  rm /usr/lib/systemd/system/auto-patcher.timer
fi

echo Finished Uninstalling Auto-Patcher!
