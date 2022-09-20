#!/bin/bash

#
# Author:       Alex Portell <https://github.com/portellam>
#

# check if sudo/root #
    if [[ `whoami` != "root" ]]; then
        str_file1=`echo ${0##/*}`
        str_file1=`echo $str_file1 | cut -d '/' -f2`
        echo -e "WARNING: Script must execute as root. In terminal, run:\n\t'sudo bash $str_file1'\n\tor\n\t'su' and 'bash $str_file1'.\nExiting."
        exit 1
    fi

# set IFS #
    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'\n'      # Change IFS to newline char

echo -en "Installing Auto-Xorg... "

# parameters #
    bool_missingFiles=false
    readonly str_outDir1="/usr/sbin/"
    readonly str_outDir2="/etc/systemd/system/"
    readonly str_inFile1="auto-xorg.bash"
    readonly str_inFile2="auto-xorg.service"

# copy files and set file permissions #
    if [[ -e $str_outDir1 && -e $str_inFile1 ]]; then
        cp $str_inFile1 ${str_outDir1}${str_inFile1}
        chown root ${str_outDir1}${str_inFile1}
        chmod +x ${str_outDir1}${str_inFile1}
    else
        bool_missingFiles=true
    fi

    if [[ -e $str_outDir2 && -e $str_inFile2 ]]; then
        cp $str_inFile2 ${str_outDir2}${str_inFile2}
        chown root ${str_outDir2}${str_inFile2}
        chmod +x ${str_outDir2}${str_inFile2}
    else
        bool_missingFiles=true
    fi

# missing files #
    if [[ $bool_missingFiles == true ]]; then
        echo -e "Failed.\n\n$0: Missing directories/files:"

        if [[ -z $str_outDir1 ]]; then echo -e "\t$str_outDir1"; fi
        if [[ -z $str_outDir2 ]]; then echo -e "\t$str_outDir2"; fi
        if [[ -z $str_inFile1 ]]; then echo -e "\t$str_inFile1"; fi
        if [[ -z $str_inFile2 ]]; then echo -e "\t$str_inFile2"; fi

# setup services #
    else
        echo -e "Complete.\n"
        systemctl enable $str_inFile2
        systemctl restart $str_inFile2
        systemctl daemon-reload
        echo -e "It is NOT necessary to run '$str_inFile1'.\n\t'$str_inFile2' will run automatically at boot, to grab the first non-VFIO VGA device.\n\tIf no available VGA device is found, an Xorg template will be created.\n\tIt will be assumed the system is running 'headless'."
    fi

echo -e "\nExiting."
IFS=$SAVEIFS   # Restore original IFS
exit 0
