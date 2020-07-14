#!/usr/bin/env bash

## Defines a Log File
logfile='/var/log/auto-patcher.log'

## Clean Orhpans and Old Packages
# Can be 'true' or 'false'
cleanup='true'

## Run A Custom Pre-Transaction Script
# Can be set to a $(command-here)
pre_transaction=''

## Run A Custom Post-Transaction Script
# Can be set to $(command-here)
post_transaction=''

## Forces a Reboot on Each Run
# Can be 'true' or 'false'
force_reboot='false'

## Disables Reboots Even If They Are Needed
# Can be 'true' or 'false'
disable_reboot='false'

## Schedules A Reboot One Min After Script Finishes
reboot_time=$(date --date='1 minute' +%H:%M)
## Can Also Be Set To a Spesific Time
#reboot_time='00:00'

