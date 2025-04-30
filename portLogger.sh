#! /bin/bash

#DETECTAR PUERTOS LIBRE/OCUPADOS
declare -i index=0;
declare -i nline=1;
declare -i nPort=0;

# dmesg -T | grep -i 'New USB device found' | while read line; do

#     nPort=$((nPort + 1))

#     if echo "$line" | grep -q "usb$((nPort))"; then
#         echo "usb$nPort"
#         echo $line
#     else
#         nPort=$((nPort - 1))
#         echo 'DEVICE FOUND IN HUB'
#         echo "usb$nPort"
#         echo $line 

#     fi

#     if echo "$line" | grep -q 'New USB device found'; then
#         echo "$line" | grep -o "usb[1-9]+"
#     elif echo "$line" | grep -q 'USB disconnect'; then

#     else

#     fi

# done

dmesg -T | grep -i 'USB' | while read line; do
    if echo "$line" | grep -q 'New USB device found'; then
        echo "USB CONNECT"
        echo "$line" | grep -E -o "usb[1-9]+"
        echo "$line" | grep -o "\[[^]]*\]"

    elif echo "$line" | grep -q 'USB disconnect'; then
        echo "USB DISCONNECT"
        echo "$line" | grep -E -o "usb[1-9]+"
        echo "$line" | grep -o "\[[^]]*\]"
    else
        echo "failure"
    fi
done



#LOGGEAR EN UN ARCHIVO UNA TABLA PUERTO POR HORA CONEXION Y HORA DESCONEXION
#DETECTAR CUANDO EL PUERTO X FUE OCUPADO/DESOCUPADO