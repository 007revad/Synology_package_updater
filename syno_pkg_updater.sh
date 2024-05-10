#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Update packages that have updates
#
# GitHub: https://github.com/007revad/Synology_package_updater
# Script verified at https://www.shellcheck.net/
#
# To run in a shell (replace /volume1/scripts/ with path to script):
# sudo /volume1/scripts/syno_pkg_updater.sh
#------------------------------------------------------------------------------

echo -e "Checking checking for package updates...\n"
updates="$(synopkg checkupdateall)"

qty="$(echo "$updates" | grep -o '{' | wc -l)"
#echo "qty: $qty"  # debug

fnum="2"
count="0"
while [[ "$count" -lt "$qty" ]]; do
    string=""
    id=""
    volume=""
    
    # Parse package
    string="$(echo "$updates" | cut -d"{" -f"$fnum")"
    #echo -e "\nstring: $string"  # debug
    
    if echo "$string" | grep 'beta":false' >/dev/null; then
        id="$(echo "$string" | cut -d"," -f2 | cut -d':' -f2 | cut -d'"' -f2)"
    fi

    # Get installed volume
    volume=$(readlink "/var/packages/$id/target" | cut -d'/' -f2)
    if [[ ! $volume =~ volume[0-9]+$ ]]; then
        volume=""
    fi

    # Update package
    if [[ "$id" ]]; then
        if [[ -n "$volume" ]]; then
            echo "Updating $id on $volume"
            synopkg install_from_server "$id" "/$volume"
        else
            echo "Updating $id"
            synopkg install_from_server "$id"
        fi
    fi

    fnum=$((fnum +1))
    count=$((count +1))
done

echo -e "\nFinished"

exit

