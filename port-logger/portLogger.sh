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
firstMsgIn=0
firstMsgOut=0
date=""
declare -i numDevs=0

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
        firstMsgIn=0;
        firstMsgOut=0;
        currDev="$port";
    fi

    if grep -q -E "add|\bbind\b" <<< "$rawLogMsg" && [[ "$firstMsgIn" == "0" ]]; then
        #INSERT CODE FOR LOGGING 1st TIME
        date=$(date +"%Y-%m-%d %H:%M:%S")
        echo "USB Connected at $date on port $nport" 
        #>> "/home/$USER/USBLogs"
        firstMsgIn=1
        currDev="$port";
        numDevs=$(($numDevs + 1));
        echo "$rawLogMsg";

    elif grep -q -E "remove|unbind" <<< "$rawLogMsg" && [[ "$firstMsgOut" == "0" ]]; then

        date=$(date +"%Y-%m-%d %H:%M:%S")
        echo "USB Disconnected at $date on port $nport" 
        #>> "/home/$USER/USBLogs"
        firstMsgOut=1
        currDev="$port";
        numDevs=$(($numDevs - 1));
        echo "$rawLogMsg";

    fi

done < <(udevadm monitor --subsystem-match=usb)

#MAKE ARRAY OF BUSY PORTS
#UDEV ALWAYS LOGS 4 MESSAGES AFTER ADDING AND REMOVING A USB?
#