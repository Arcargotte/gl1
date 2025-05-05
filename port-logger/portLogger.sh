#! /bin/bash

#INIATE
#CREATE FILE FOR USB LOGS IF IT DOESN'T EXISTS
#OTHERWISE, CREATE USB LOG AT /home/$USER/usblogs
#WRITE TO LOG EVERY TIME IT DETECTS 'USB' AT A MESSAGE LOG

rawLogMsg=
port=
nport=
logMsg=
currDev=
firstMsg=0
bounded=1
date=""

if find /home/$USER -type f -name "USBLogs" | grep -q .; then
    echo "Logs found at /home/$USER"
    #INITIATE PROGRAM
else
    touch "/home/$USER/USBLogs"
    echo "USBLogs file has been created at /home/$USER"
    echo "Check the contents of the file to read the logs from available ports"
fi

while read rawLogMsg; do

    port=$(grep -o -E "usb[0-9]+/[0-9]+-[0-9]+" <<< "$rawLogMsg")

    nport=$(echo "$port" | sed -E 's/.*-([0-9]+).*/\1/')

    if [[ "$currDev" != "$port" ]]; then
        firstMsg=0
        currDev="$port"
    fi

    if grep -q -E "add|bind" <<< "$rawLogMsg"; then
        if [[ "$firstMsg" != "0" ]] && [[ "$currDev" == "$port" ]] && [[ "$bounded" == "1" ]]; then
            firstMsg=0
        fi

        if [[ "$firstMsg" == "0" ]]; then
            #INSERT CODE FOR LOGGING 1st TIME
            date=$(date +"%Y-%m-%d %H:%M:%S")
            echo "USB Connected at $date on port $nport" >> "/home/$USER/USBLogs"
            firstMsg=1
            bounded=0
        fi

    elif grep -q -E "remove|unbind" <<< "$rawLogMsg"; then
        if [[ "$firstMsg" != "0" ]] && [[ "$currDev" == "$port" ]] && [[ "$bounded" == "0" ]]; then
            firstMsg=0
        fi

        if [[ "$firstMsg" == "0" ]]; then
            date=$(date +"%Y-%m-%d %H:%M:%S")
            echo "USB Disconnected at $date on port $nport" >> "/home/$USER/USBLogs"

            firstMsg=1
            bounded=1
        fi

    fi

    #echo "$rawLogMsg"
    # echo ">>> USB: $nport <<<"
    # echo "Dispositivo: $currDev"
done < <(udevadm monitor --subsystem-match=usb)

#MAKE ARRAY OF BUSY PORTS
#UDEV ALWAYS LOGS 4 MESSAGES AFTER ADDING AND REMOVING A USB?
#