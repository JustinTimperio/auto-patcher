#!/usr/bin/env bash

# Set Main Vars
source config.sh
osname=$(cat /etc/*release | grep -Pi '^ID=' | head -1 | cut -c4- | sed -e 's/^"//' -e 's/"$//')

# Start Logging 
echo ---------- $(date) ---------- >> $logfile
echo [$(date +%T)] Started Auto-Patcher... >> $logfile


# Run Upgrades Per OS and Report Reboot Status

## DEBIAN
if [[ $osname == 'ubuntu' ]] || [[ $osname == 'debian' ]]; then
  ### Update System
  apt update --yes >> $logfile
  apt upgrade --yes >> $logfile
  
  if [[ $cleanup == 'true' ]]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $logfile 
    apt clean --yes >> $logfile
    apt autoremove --yes >> $logfile 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By config.sh! >> $logfile
  fi

  ### Check if System Needs to Be Rebooted
  if [ -f /var/run/reboot-required ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $logfile 
    $reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $logfile 
    $reboot_needed='false'
  fi

## CENTOS
elif [[ $osname == 'centos' ]]; then
  ### Update and Upgrade System
  yum -y upgrade >> $logfile
  
  if [[ $cleanup == 'true' ]]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $logfile 
    yum -y autoremove >> $logfile 
    yum -y clean all >> $logfile
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By config.sh! >> $logfile
  fi

  ### Check if System Needs to Be Rebooted
  if [$(needs-restarting  -r ; echo $?) == 0]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $logfile 
    $reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $logfile 
    $reboot_needed='false'
  fi

## ARCH
elif [[ $osname == 'arch' ]] || [[ $osname == 'manjaro' ]]; then
  ### Update and Upgrade System
  pacman -Syu --noconfirm >> $logfile
  
  ### Clean Orphans
  if [[ $cleanup == 'true' ]]; then
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $logfile 
    pacman -Rns $(pacman -Qtdq) --noconfirm >> $logfile
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By config.sh! >> $logfile
  fi

  ### Checks Kernel Versions in /boot
  NEXTLINE=0
  FIND=""
  for I in `file /boot/vmlinuz*`; do
    if [ ${NEXTLINE} -eq 1 ]; then
      FIND="${I}"
      NEXTLINE=0
     else
      if [ "${I}" = "version" ]; then NEXTLINE=1; fi
    fi
  done

  ### Compares Running Kernel Against Kernel Installed in /boot
  if [ ! "${FIND}" = "" ]; then
    CURRENT_KERNEL=`uname -r`
    if [ ! "${CURRENT_KERNEL}" = "${FIND}" ]; then
      echo [$(date +%T)] The System Needs to Be Rebooted! >> $logfile 
      $reboot_needed='true'
    else 
      echo [$(date +%T)] The System Does Not Require a Reboot. >> $logfile 
      $reboot_needed='false'
    fi
  fi

## NOT SUPPORTED
else
  echo [$(date +%T)] $osname Is Not Supported! >> $logfile
  $reboot_needed='false'
fi


# Decide If Reboot Should Be Scheduled
if [[ $disable_reboot == 'true' ]]; then
  echo [$(date +%T)] Reboot Has Been Disabled By config.sh! >> $logfile

elif [[ $force_reboot == 'true' ]]; then
  echo [$(date +%T)] Reboot is Being Forced By config.sh! >> $logfile
  shutdown -r $reboot_time >> $logfile

elif [[ $reboot_needed == 'true' ]]; then
  echo [$(date +%T)] Reboot is Required and Will Be Scheduled At $reboot_time >> $logfile
  shutdown -r $reboot_time >> $logfile
fi


# Finish Logging and Exit
echo [$(date +%T)] Auto-Patcher Finished. >> $logfile
