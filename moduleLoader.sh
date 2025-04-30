#! /bin/bash

#GET MODULE NAME
#CHECK WHETHER IT'S LOADED
#IF SO, ASKS FOR USER TO DOWNLOAD
#TO DOWNLOAD
# 1. Download()
# 2. IF IN USE, STOP SERVICES AND TRY AGAIN
#OTHERWISE, ASKS FOR USER TO LOAD
#TO LOAD:
# 1. FIND MODULE
# 2. IF EXISTS, load(module)
# OTHERWISE, PROMPT USER

if [ -n "$1" ] && find /lib/modules/6.12.13-amd64/kernel -type f -name "$1" > /dev/null ; then
    echo "Success!";
else
    echo "Please, provide a valid module name";
    exit
fi

if lsmod | grep -q "$1"; then
    echo "The module is loaded"
    echo "Do you want to download the module? [Y/N]"
    read -n 1 usrPrompt
    echo

    if [[ "$usrPrompt" == [Yy] ]]; then
        if sudo modprobe -q -r "$1"; then
            echo "Module downloaded successfully"
            exit
        else
            echo "Downloading a module in use may result in system unexpected behavior."
            echo "Manually check the services that use the module to download"
            echo "Stopped module downloading"

            exit
        fi
    else
        exit
    fi
else
    echo "The module is not loaded"
    echo "Do you want to load the module? [Y/N]"
    read -n 1 usrPrompt
    echo

    if [[ "$usrPrompt" == [Yy] ]]; then
        if sudo modprobe "$1"; then
            echo "Module loaded succesfully"
            exit
        else
            echo "Fatal error"
            exit
        fi
    else
        exit
    fi
fi