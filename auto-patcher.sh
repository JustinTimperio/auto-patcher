#! /usr/bin/env sh

# Set Main Vars
. /etc/auto-patcher/config

# Start Logging 
echo '' >> "$log" 2>&1
echo '' >> "$log" 2>&1
echo "=================================================" >> "$log" 2>&1
echo "         $(date)" >> "$log" 2>&1
echo "=================================================" >> "$log" 2>&1
echo [$(date +%T)] Started Auto-Patcher... >> "$log" 2>&1


#################################################
# Check If a Pre-Transaction Script is Defined
###############################################


if [ -n "$pre_transaction" ]; then 
  echo [$(date +%T)] Started Running Custom Pre-Transaction Script. >> "$log" 2>&1 
  $pre_transaction
  echo [$(date +%T)] Finished Running Custom Pre-Transaction Script. >> "$log" 2>&1 
else 
  echo [$(date +%T)] No Pre-Transaction Command Defined. >> "$log" 2>&1 
fi


#################################################
# Run Upgrades Per OS and Report Reboot Status
###############################################


if [ "$(uname)" = 'FreeBSD' ]; then
  osname="freebsd"
else
  osname=$(cat /etc/*release | grep -Pi '^ID=' | head -1 | cut -c4- | sed -e 's/^"//' -e 's/"$//')
fi

echo [$(date +%T)] Detected the Operating System: "$osname" >> "$log" 2>&1 


#############################
## DEBIAN
#############################
if [ "$osname" = 'ubuntu' ] || [ "$osname" = 'debian' ]; then
  ### Update System
  echo '' >> "$log" 2>&1 
  apt update --yes >> "$log" 2>&1
  apt upgrade --yes >> "$log" 2>&1
  echo '' >> "$log" 2>&1 
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> "$log" 2>&1 
    echo '' >> "$log" 2>&1 
    apt clean --yes >> "$log" 2>&1
    apt autoremove --yes >> "$log" 2>&1 
    echo '' >> "$log" 2>&1 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> "$log" 2>&1
  fi

  ### Check if System Needs to Be Rebooted
  if [ -f /var/run/reboot-required ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> "$log" 2>&1 
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> "$log" 2>&1 
    reboot_needed='false'
  fi

#############################
## RHL
#############################
elif [ "$osname" = 'centos' ] || [ "$osname" = 'fedora' ]; then
  ### Update and Upgrade System
  echo '' >> "$log" 2>&1 
  yum -y upgrade >> "$log" 2>&1
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> "$log" 2>&1 
    echo '' >> "$log" 2>&1 
    yum -y autoremove >> "$log" 2>&1 
    yum -y clean all >> "$log" 2>&1
    echo '' >> "$log" 2>&1 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> "$log" 2>&1
  fi

  ### Check if System Needs to Be Rebooted
  if [ $(needs-restarting  -r ; echo $?) = 0 ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> "$log" 2>&1
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> "$log" 2>&1
    reboot_needed='false'
  fi

#############################
## OpenSUSE
#############################
elif [ "$osname" = 'opensuse-leap' ] || [ "$osname" = 'opensuse-tumbleweed' ]; then
  ### Update and Upgrade System
  echo '' >> "$log" 2>&1 
  zypper -n refresh  >> "$log" 2>&1
  zypper -n update >> "$log" 2>&1
  echo '' >> "$log" 2>&1 
  
  if [ "$cleanup" = 'true' ]; then
    ### Cleanup
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> "$log" 2>&1
    echo '' >> "$log" 2>&1 
    zypper -n cc -a >> "$log" 2>&1
    echo '' >> "$log" 2>&1 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> "$log" 2>&1
  fi

  ### Check if System Needs to Be Rebooted
  zyp_report=$(zypper ps -s | grep -o)
  
  if [ "$zyp_report" = 'Reboot is required' ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> "$log" 2>&1 
    reboot_needed='true'
  else
    echo [$(date +%T)] The System Does Not Require a Reboot. >> "$log" 2>&1 
    reboot_needed='false'
  fi

#############################
## ARCH
#############################
elif [ "$osname" = 'arch' ] || [ "$osname" = 'manjaro' ]; then
  ### Update and Upgrade System
  echo '' >> "$log" 2>&1 
  pacman -Syu --noconfirm >> "$log" 2>&1
  echo '' >> "$log" 2>&1 
  
  ### Clean Orphans
  if [ "$cleanup" = 'true' ]; then
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> "$log" 2>&1 
    echo '' >> "$log" 2>&1 
    pacman -Rns $(pacman -Qtdq) --noconfirm >> "$log" 2>&1
    echo '' >> "$log" 2>&1 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> "$log" 2>&1
  fi

  ### Checks Kernel Version in /boot
  INSTALLED_KERNEL=$(file -bL /boot/vmlinuz* | grep -o 'version [^ ]*' | cut -d ' ' -f 2) 
  ### Fetch Running Kernel
  RUNNING_KERNEL=$(uname -r)

  ### Compares Running Kernel Against Installed Kernel
  if [ "$INSTALLED_KERNEL" != "$RUNNING_KERNEL" ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> "$log" 2>&1 
    echo [$(date +%T)] Kernel Changed From "$RUNNING_KERNEL" to "$INSTALLED_KERNEL"! >> "$log" 2>&1 
    reboot_needed='true'
  else 
    echo [$(date +%T)] The System Does Not Require a Reboot. >> "$log" 2>&1 
    reboot_needed='false'
  fi

#############################
## FreeBSD
#############################
elif [ "$osname" = 'freebsd' ]; then
  ### Update and Upgrade System
  echo '' >> "$log" 2>&1
  yes | pkg upgrade >> "$log" 2>&1
  echo '' >> "$log" 2>&1
  
  ### Clean Orphans
  if [ "$cleanup" = 'true' ]; then
    echo [$(date +%T)] Starting System Package Maintaince and Cleanup... >> "$log" 2>&1 
    echo '' >> "$log" 2>&1 
    yes | pkg autoremove >> "$log" 2>&1
    echo '' >> "$log" 2>&1 
  else
    echo [$(date +%T)] Package Cleanup Is Disabled By /etc/auto-patcher/config! >> "$log" 2>&1
  fi
  
  ### Checks Kernel Version in /boot
  INSTALLED_KERNEL=$(freebsd-version -k) 
  ### Fetch Running Kernel
  RUNNING_KERNEL=$(uname -r)

  ### Compares Running Kernel Against Installed Kernel
  if [ "$INSTALLED_KERNEL" != "$RUNNING_KERNEL" ]; then
    echo [$(date +%T)] The System Needs to Be Rebooted! >> "$log" 2>&1 
    echo [$(date +%T)] Kernel Changed From "$RUNNING_KERNEL" to "$INSTALLED_KERNEL"! >> "$log" 2>&1 
    reboot_needed='true'
  else 
    echo [$(date +%T)] The System Does Not Require a Reboot. >> "$log" 2>&1 
    reboot_needed='false'
  fi

#############################
## NOT SUPPORTED
#############################
else
  echo [$(date +%T)] "$osname" Is Not Supported! >> "$log" 2>&1
  exit
fi


##################################################
# Check If a Post-Transaction Script is Defined
################################################

if [ -n "$post_transaction" ]; then 
  echo [$(date +%T)] Started Running Custom Post-Transaction Script. >> "$log" 2>&1 
  $post_transaction
  echo [$(date +%T)] Finished Running Custom Post-Transaction Script. >> "$log" 2>&1 

else 
  echo [$(date +%T)] No Post-Transaction Command Defined. >> "$log" 2>&1 
fi


##########################################
# Decide If Reboot Should Be Scheduled
#######################################

if [ "$disable_reboot" = 'true' ]; then
  echo [$(date +%T)] Reboot Has Been Disabled By /etc/auto-patcher/config! >> "$log" 2>&1

elif [ "$force_reboot" = 'true' ]; then
  echo [$(date +%T)] Reboot is Being Forced By /etc/auto-patcher/config! >> "$log" 2>&1
  shutdown -r "$reboot_time" >> "$log" 2>&1

elif [ "$reboot_needed" = 'true' ]; then
  echo [$(date +%T)] Reboot is Required and Will Be Scheduled "$reboot_time" Mins in the Future >> "$log" 2>&1
  shutdown -r +"$reboot_offset" 'Auto-Patcher Has Scheduled a Reboot After a System Upgrade' >> "$log" 2>&1
fi


# Finish Logging and Exit
echo [$(date +%T)] Auto-Patcher Finished. >> "$log" 2>&1
