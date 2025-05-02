#! /bin/bash

#INIATE
#CREATE FILE FOR USB LOGS IF IT DOESN'T EXISTS
#OTHERWISE, CREATE USB LOG AT /home/$USER/usblogs
#WRITE TO LOG EVERY TIME IT DETECTS 'USB' AT A MESSAGE LOG

rawLogMsg=
nport=
logMsg=
currDev=
firstMsg=0
bounded=1
date=""

if find /home/$USER -type f -name "USBLogs" | grep -q .; then
    echo "FILE FOUND"
    #INITIATE PROGRAM
else
    touch "/home/$USER/USBLogs"
    echo "USBLogs file has been created at /home/$USER"
    echo "Check the contents of the file to read the logs from available ports"
fi

while read rawLogMsg; do

    nport=$(grep -o -E "usb[0-9]+/[0-9]+-[0-9]+" <<< "$rawLogMsg")

    # if [[ "$rawLogMsg" =~ (usb[0-9]+-[0-9]+|[a-z]+[0-9]+) ]]; then
    #     nport="${BASH_REMATCH[0]}"
    # else
    #     nport="unknown"
    # fi

    if [[ "$currDev" != "$nport" ]]; then
        firstMsg=0
        currDev="$nport"
    fi


    if grep -q -E "add|bind" <<< "$rawLogMsg"; then

        if [[ "$firstMsg" != "0" ]] && [[ "$currDev" == "$nport" ]] && [[ "$bounded" == "1" ]]; then
            firstMsg=0
        fi

        if [[ "$firstMsg" == "0" ]]; then
            #INSERT CODE FOR LOGGING 1st TIME
            date=$(date +"%Y-%m-%d %H:%M:%S")

            echo "$date USB CONNECTED: $nport"
            firstMsg=1
            bounded=0
        fi

    elif grep -q -E "remove|unbind" <<< "$rawLogMsg"; then

        if [[ "$firstMsg" != "0" ]] && [[ "$currDev" == "$nport" ]] && [[ "$bounded" == "0" ]]; then
            firstMsg=0
        fi

        if [[ "$firstMsg" == "0" ]]; then
            echo "$date USB DISCONNECTED: $nport"

            firstMsg=1
            bounded=1
        fi

    fi

    echo "$rawLogMsg"
    # echo ">>> USB: $nport <<<"
    # echo "Dispositivo: $currDev"
done < <(udevadm monitor --subsystem-match=usb)

#MAKE ARRAY OF BUSY PORTS
#UDEV ALWAYS LOGS 4 MESSAGES AFTER ADDING AND REMOVING A USB?
#