#! /bin/bash

#INITIATE
#VERIFY IF LOGGER FILE ALREADY EXISTS.
#IF SO, STARTS EXECUTION
#OTHERWISE, PROMPT USER FOR FILE NAME AND STARTS EXECUTION
#IN THE PROGRAM, GIVE USER THE FOLLOWING OPTIONS
# (1) PRINT STORED REFERENCES
# (2) ADD NEW REFERENCE
# (3) ERASE REFERENCE
# (4) CHANGE ACCESS CONTROL 
# (5) END PROGRAM

# BY DEFAULT, FILE NAME IS refcontrol AT /home/$USER

usrInput=
usrPrompt=

if find /home/$USER -type f -name "refcontrol" | grep -q .; then
    echo "FILE FOUND"
    echo "$fileExists"
    #INITIATE PROGRAM
else
    touch "/home/$USER/refcontrol"
    echo "refcontrol file has been created at /home/$USER"
    echo "Check the contents of the file to read any references"

fi

while [[ 0 == 0 ]]; do
    echo "(1) Print references"
    echo "(2) Add reference"
    echo "(3) Erase reference"
    echo "(4) Change access control"
    echo "(5) Exit"

    read -n 1 usrPrompt
    echo

    if [[ $usrPrompt == 1 ]]; then
        echo "Printing references..."

        while IFS= read -r linea; do
            echo "$linea"
        done < /home/$USER/refcontrol

    elif [[ $usrPrompt == 2 ]]; then
        echo "Adding references..."
        #CHECK IF REFERENCE EXISTS find /home/$USER -type f -name "refcontrol" | grep -q .
        #CHECK IF FILE EXISTS
        #CHECK IF FILE IS A DEVICE
        #CREATE REFERENCE
        read usrInput

        reference=$(awk '{ print $1 }' <<< $usrInput)
        refPath=$(awk '{ print $2 }' <<< $usrInput)

        if grep -q "$reference" /home/$USER/refcontrol; then
            echo "Reference already exists. Aborting!"
            exit
        fi

        if find "$refPath" | grep -q .; then
            echo "Checking file..."
            if grep -q "/dev/" <<< "$refPath"; then
                echo "File is a device. Aborting!"
            else
                echo $usrInput >> /home/"$USER"/refcontrol
                echo "Reference added successfully"
                echo "Creating reference"
            fi
        else
            echo "File doesn't exist. Aborting!"
            exit
        fi

    elif [[ $usrPrompt == 3 ]]; then
        echo "Erasing references..."

    elif [[ $usrPrompt == 4 ]]; then
        echo "Changing access control..."
    elif [[ $usrPrompt == 5 ]]; then
        echo "Finishing program..."
        exit
    else
        echo "Invalid entry. Please, try again"
    fi
done