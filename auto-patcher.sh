#! /usr/bin/env sh

# Set Main Vars
. /etc/auto-patcher/config

# Start Logging 
echo '' >> $log
echo ---------- $(date) ---------- >> $log
echo [$(date +%T)] Started Auto-Patcher... >> $log


#################################################
# Check If a Pre-Transaction Script is Defined
###############################################


if [ -n "$pre_transaction" ]; then 
  echo [$(date +%T)] Started Running Custom Pre-Transaction Script. >> $log 
  $pre_transaction
  echo [$(date +%T)] Finished Running Custom Pre-Transaction Script. >> $log 
else 
  echo [$(date +%T)] No Pre-Transaction Command Defined. >> $log 
fi


#################################################
# Run Upgrades Per OS and Report Reboot Status
###############################################


if [ "$(uname)" = 'FreeBSD' ]; then
  osname="freebsd"
else
  osname=$(cat /etc/*release | grep -Pi '^ID=' | head -1 | cut -c4- | sed -e 's/^"//' -e 's/"$//')
fi

echo [$(date +%T)] Detected the Operating System: $osname >> $log 


#############################
## DEBIAN
#############################
if [ "$osname" = 'ubuntu' ] || [ "$osname" = 'debian' ]; then
  ### Update System
  apt update --yes >> $log
  apt upgrade --yes >> $log
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $log 
    apt clean --yes >> $log
    apt autoremove --yes >> $log 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> $log
  fi

  ### Check if System Needs to Be Rebooted
  if [ -f /var/run/reboot-required ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $log 
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $log 
    reboot_needed='false'
  fi


#############################
## RHL
#############################
elif [ "$osname" = 'centos'] || [ "$osname" = 'fedora' ]; then
  ### Update and Upgrade System
  yum -y upgrade >> $log
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $log 
    yum -y autoremove >> $log 
    yum -y clean all >> $log
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> $log
  fi

  ### Check if System Needs to Be Rebooted
  if [ $(needs-restarting  -r ; echo $?) = 0 ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $log
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $log
    reboot_needed='false'
  fi


#############################
## OpenSUSE
#############################
elif [ "$osname" = 'opensuse-leap' ] || [ "$osname" = 'opensuse-tumbleweed' ]; then
  ### Update and Upgrade System
  zypper -n refresh  >> $log
  zypper -n update >> $log
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $log
    zypper -n cc -a >> $log
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> $log
  fi

  ### Check if System Needs to Be Rebooted
  zyp_report=$(zypper ps -s | grep -o)
  
  if [ "$zyp_report" = 'Reboot is required' ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $log 
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $log 
    reboot_needed='false'
  fi

#############################
## ARCH
#############################
elif [ "$osname" = 'arch' ] || [ "$osname" = 'manjaro' ]; then
  ### Update and Upgrade System
  pacman -Syu --noconfirm >> $log
  
  ### Clean Orphans
  if [ "$cleanup" = 'true' ]; then
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $log 
    pacman -Rns $(pacman -Qtdq) --noconfirm >> $log
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> $log
  fi

  ### Checks Kernel Version in /boot
  INSTALLED_KERNEL=$(file -bL /boot/vmlinuz* | grep -o 'version [^ ]*' | cut -d ' ' -f 2) 
  ### Fetch Running Kernel
  RUNNING_KERNEL=$(uname -r)

  ### Compares Running Kernel Against Installed Kernel
  if [ $INSTALLED_KERNEL != $RUNNING_KERNEL ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $log 
    echo [$(date +%T)] Kernel Changed From $RUNNING_KERNEL to $INSTALLED_KERNEL! >> $log 
    reboot_needed='true'
  else 
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $log 
    reboot_needed='false'
  fi


#############################
## FreeBSD
#############################
elif [ "$osname" = 'freebsd' ]; then
  ### Update and Upgrade System
  yes | pkg upgrade >> $log
  
  ### Clean Orphans
  if [ "$cleanup" = 'true' ]; then
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> $log 
    yes | pkg autoremove >> $log
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> $log
  fi
  
  ### Checks Kernel Version in /boot
  INSTALLED_KERNEL=$(freebsd-version -k) 
  ### Fetch Running Kernel
  RUNNING_KERNEL=$(uname -r)

  ### Compares Running Kernel Against Installed Kernel
  if [ $INSTALLED_KERNEL != $RUNNING_KERNEL ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> $log 
    echo [$(date +%T)] Kernel Changed From $RUNNING_KERNEL to $INSTALLED_KERNEL! >> $log 
    reboot_needed='true'
  else 
    echo [$(date +%T)] The System Does Not Require a Reboot. >> $log 
    reboot_needed='false'
  fi


## NOT SUPPORTED
else
  echo [$(date +%T)] $osname Is Not Supported! >> $log
  exit
fi


##################################################
# Check If a Post-Transaction Script is Defined
################################################

if [ -n "$post_transaction" ]; then 
  echo [$(date +%T)] Started Running Custom Post-Transaction Script. >> $log 
  $post_transaction
  echo [$(date +%T)] Finished Running Custom Post-Transaction Script. >> $log 

else 
  echo [$(date +%T)] No Post-Transaction Command Defined. >> $log 
fi


##########################################
# Decide If Reboot Should Be Scheduled
#######################################

if [ "$disable_reboot" = 'true' ]; then
  echo [$(date +%T)] Reboot Has Been Disabled By /etc/auto-patcher/config! >> $log

elif [ "$force_reboot" = 'true' ]; then
  echo [$(date +%T)] Reboot is Being Forced By /etc/auto-patcher/config! >> $log
  shutdown -r $reboot_time >> $log

elif [ "$reboot_needed" = 'true' ]; then
  echo [$(date +%T)] Reboot is Required and Will Be Scheduled At $reboot_time >> $log
  shutdown -r +$reboot_offset "Auto-Patcher Has Scheduled a Reboot After a System Upgrade" >> $log
fi


# Finish Logging and Exit
echo [$(date +%T)] Auto-Patcher Finished. >> $log
