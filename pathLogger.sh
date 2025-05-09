#! /bin/bash

# Creates a reference file refcontrol at /home/$USER to store
# an alias for path to a file. 

# (1) Checks if file exists. If exists, proceeds to program.
# Otherwise created refcontrol.

# BY DEFAULT, FILE NAME IS refcontrol AT /home/$USER

if ! find /home/$USER -type f -name "refcontrol" | grep -q .; then
    touch "/home/$USER/refcontrol"
    echo "refcontrol file has been created at /home/$USER"
    echo "Check the contents of the file to read any references"
fi

#Through usage of getopts, script works as a bash command.
#With a flag as an input, proceeds to case for program to work.
#Flags:
# -h: prints usage of command
# -p: prints stored references 
# -a [REFERENCE] [PATHNAME]: adds a single non-existing reference to pathname into refcontrol 
# -e [REFERENCE]: deletes reference in refcontrol
# -c [REFERENCE] [CHMOD ARGUMENT]: changes access control of reference.

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
            refPath=$(awk '{ print $2 }' <<< $OPTARG)

            if grep -q "$reference" /home/$USER/refcontrol || grep -q "$refPath" /home/$USER/refcontrol; then
                echo "Reference already exists. Aborting!"
                exit
            fi

            #Checks if pathname exists in refcontrol. The command grep -q . checks if finds returns
            #a nonempty reference
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
            echo "Using -a to add the pair [REFERENCE] [PATH] must be enclosed in double quotes"
            echo "-r    remove a reference"
            echo "-c    change access control of reference"
            echo "Using -c to add the pair [REFERENCE] [OCTAL-MODE CODE] must be enclosed in double quotes"


        ;;
    esac

done