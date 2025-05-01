#! /bin/bash

#INIATE
#CREATE FILE FOR USB LOGS IF IT DOESN'T EXISTS
#OTHERWISE, CREATE USB LOG AT /home/$USER/usblogs
#WRITE TO LOG EVERY TIME IT DETECTS 'USB' AT A MESSAGE LOG

rawLogMsg=
nport=
ndate=
logMsg=
currDev=

udevadm monitor --subsystem-match=usb | while read rawLogMsg; do

    nport=$(grep -o -E "usb[0-9]?" <<< "$rawLogMsg")

    if [[ "$currDev" != "$nport" ]]; then
        firstBind=0
        currDev="$nport"
    fi


    if grep -q "add" <<< "$rawLogMsg"; then

        if [[ firstBind == 0 ]]; then
            #INSERT CODE FOR LOGGING 1st TIME
            echo "USB CONNECTED: $nport"

            firstBind=1
        fi #IGNORE
    elif grep -q "remove" <<< "$rawLogMsg"; then

        if [[ firstBind == 0 ]]; then
            echo "USB DISCONNECTED: $nport"

            firstBind=1
        fi
    fi
done

#MAKE ARRAY OF BUSY PORTS
#UDEV ALWAYS LOGS 4 MESSAGES AFTER ADDING AND REMOVING A USB?
#