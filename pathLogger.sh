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

if ! find /home/$USER -type f -name "refcontrol" | grep -q .; then
    touch "/home/$USER/refcontrol"
    echo "refcontrol file has been created at /home/$USER"
    echo "Check the contents of the file to read any references"
fi

while getopts "hpa:r:c:" o; do
    reference=
    refpath=

    case "$o" in
        :)
            echo "  Option -$o requires an argument."
        ;;
        p)
            echo "Printing references..."
            awk '{ print $0 }' /home/$USER/refcontrol
        ;;
        a)
            echo "Adding references..."
            #CHECK IF REFERENCE EXISTS find /home/$USER -type f -name "refcontrol" | grep -q .
            #CHECK IF FILE EXISTS
            #CHECK IF FILE IS A DEVICE
            #CREATE REFERENCE

            reference=$(awk '{ print $1 }' <<< $OPTARG)
            echo "$reference"
            refPath=$(awk '{ print $2 }' <<< $OPTARG)
            echo "$refPath"

            if grep -q "$reference" /home/$USER/refcontrol; then
                echo "Reference already exists. Aborting!"
                exit
            fi

            if find "$refPath" | grep -q .; then
                echo "Checking file..."
                if grep -q "/dev/" <<< "$refPath"; then
                    echo "File is a device. Aborting!"
                else
                    echo "$reference $refPath" >> /home/"$USER"/refcontrol
                    echo "Reference added successfully"
                fi
            else
                echo "File doesn't exist. Aborting!"
                exit
            fi
        ;;
        r)
            echo "Erasing references..."

            reference=$(awk '{ print $1 }' <<< $OPTARG)

            if grep -q "$reference" /home/$USER/refcontrol; then
                touch /home/$USER/temp
                awk -v varReference="$reference" '$1 != varReference' /home/$USER/refcontrol > /home/$USER/temp
                cat /home/$USER/temp > /home/$USER/refcontrol
                rm /home/$USER/temp

                echo "Reference erased successfully"
            else
                echo "Reference doesn't exist. Aborting!"
            fi
        ;;
        c)
            accessControl=$(awk '{ print $2 }' <<< $OPTARG)
            reference=$(awk '{ print $1 }' <<< $OPTARG)

            if grep -q "$reference" /home/$USER/refcontrol; then
                refPath=$(grep "$reference" /home/$USER/refcontrol | awk '{print $2}')
                chmod "$accessControl" "$refPath"

                echo "Access control of reference changed successfully!"
            else
                echo "Reference doesn't exist. Aborting!"
            fi
            ;;

        h)
            echo "Usage: pathLogger [OPTION]"
            echo "or: pathLogger [OPTION] 'REFERENCE [PATH TO REFERENCE]'"
            echo "or: pathLogger [OPTION] 'REFERENCE OCTAL-MODE CODE'"
            echo "For more than two arguments passed to command must be enclosed in double quotes."
            echo
            echo "-p    prints all references"
            echo "-a    add a new reference"
            echo "-r    remove a reference"
            echo "-c    change access control of reference"

        ;;
    esac

done