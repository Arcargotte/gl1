#! /bin/bash

currPath="$(pwd)/rule-maker.sh"
rule="ACTION==\"add\", SUBSYSTEM==\"usb\", RUN+=\"$currPath add %p\", ENV{DEVTYPE}==\"usb_device\"
ACTION==\"remove\", SUBSYSTEM==\"usb\", RUN+=\"$currPath remove %p\", ENV{DEVTYPE}==\"usb_device\""

#CREATES RULE
#UDEV ONLY IDENTIFIES EVENTS OF DEVTYPE=usb_device TO LOG ONLY ONE OCURRENCE 
#OF THE EVENT IN CASE OF PLUGGING OR UNPLUGGING A USB INTO ONE OF THE PHYSICAL
#PORTS.
#
#(!) IT HAS NOT BEEN TESTED IN SYSTEMS WITH USB HUB EXTENSIONS.

if [ ! -f "/etc/udev/rules.d/usb-port-logger.rules" ]; then
    echo "$rule" | sudo tee /etc/udev/rules.d/usb-port-logger.rules > /dev/null
    sudo udevadm control --reload
    sudo udevadm trigger
fi

#CREATES LOG FILE BY DEFAULT AT /HOME

if [ ! -f "/home/USBLogs.txt" ]; then
    sudo touch "/home/USBLogs.txt";
    echo "USBLogs file has been created at /home";
    echo "Check the contents of the file to read the logs from available ports";
else
    port=$(grep -o -E "usb[0-9]+/[0-9]+-[0-9]+" <<< $2)
    nport=$(echo "$port" | sed -E 's/.*-([0-9]+).*/\1/')
    if [[ $1 == "add" ]]; then
        echo "($(date "+%Y/%m/%d %a %H:%M:%S")): USB plugged on port $nport" >> /home/USBLogs.txt
    elif [[ $1 == "remove" ]]; then
        echo "($(date "+%Y/%m/%d %a %H:%M:%S")): USB unplugged on port $nport" >> /home/USBLogs.txt
    fi
fi