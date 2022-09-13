#!/bin/sh
# Script ClamAV for Red Hat Enterprice Linux.
# Author Jonathan Sanfilippo
# Date Tue 13 Sep 2022
# Copyright (C) 2022 Jonathan Sanfilippo <jonathansanfilippo.uk@gmail.com>


#url
ICON="$HOME/.local/share/clamav/img/icon.svg"
LOGFILE="$HOME/.local/share/clamav/data/avlog"



get_Variables(){
TIME=$(date +%H)
data=$(date +%d)
dailylog=$(tail "$LOGFILE"|grep "Start Date:"|cut -d":" -f4);
AVset=$(cat "$HOME/.local/share/clamav/data/avset")
x="$data $AVset"
DIR=$(cat "$HOME/.local/share/clamav/data/avdir") #---------- "/" default set all system
}
  
while true; do
get_Variables

if ! [ -x "$(command -v clamscan --help)" ]; then #------------ check if clamav is installed on your system.
      exit; # ------------------------------if clamav is not installed, closes the loop.
else   
      
      if [ "$TIME" -eq "$AVset" ]; then #---------if clamav is installed on the system, check if it is the correct time to perform the scan.
            if [ "$x" = "$dailylog" ]; then
                echo "not today!"
            else 
                  notify-send -i "$ICON"  -a "Antivirus"  "Antivirus start to scan $DIR"   -u normal -t 5000;
                  nice -n19 clamscan -ri $DIR > "$LOGFILE";
                  MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);
                 if [ "$MALWARE" -eq "0" ];then
                       notify-send -i "$ICON"  -a "Antivirus"  "System Protect"   -u critical;
                       else
                       notify-send -i "$ICON"  -a "Antivirus"  "$MALWARE Malware detected"   -u critical;
                 fi                 
            fi
      elif  [ "$AVset" = "000" ]; then #-----if set 000 clamav its disabled
      echo "Disabled"
      fi          
fi
sleep 1800 
get_Variables           
done

