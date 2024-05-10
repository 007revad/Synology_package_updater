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

# [{"beta":false,"id":"git","name":"Git","version":"2.45.0-31"}]

echo -e "Checking checking for package updates...\n"
updates="$(synopkg checkupdateall)"

#updates="[{"beta":false,"id":"git","name":"Git","version":"2.45.0-31"}{"beta":false,"id":"popcorn","name":"Popcorn","version":"10.1"}{"beta":false,"id":"foobar","name":"FooBar","version":"10.1"}]"

#updates='[{"beta":false,"id":"git","name":"Git","version":"2.45.0-31"}\
#    {"beta":false,"id":"Python3.9","name":"Python3.9","version":"3.9.14-0010"}\
#    {"beta":false,"id":"LogCenter","name":"LogCenter","version":"1.2.5-1328"}]\
#    {"beta":false,"id":"FileStation","name":"FileStation","version":"1.4.1-1559"}]'

#updates='[{"beta":false,"id":"git","name":"Git","version":"2.45.0-31"}{"beta":false,"id":"Python3.9","name":"Python3.9","version":"3.9.14-0010"}'

#updates='[{"beta":false,"id":"git","name":"Git","version":"2.45.0-31"}{"beta":false,"id":"Python3.9","name":"Python3.9","version":"3.9.14-0010"}{"beta":false,"id":"LogCenter","name":"LogCenter","version":"1.2.5-1328"}]{"beta":false,"id":"FileStation","name":"FileStation","version":"1.4.1-1559"}]'


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
    #    echo "1 $id"  # debug
    #else              # debug
    #    echo "2"      # debug
    fi

    # Get installed volume
    volume=$(readlink "/var/packages/$id/target" | cut -d'/' -f2)
    if [[ ! $volume =~ volume[0-9]+$ ]]; then
        volume=""
    fi

    # Update package
    if [[ "$id" ]]; then
        if [[ -n "$volume" ]]; then
            echo -e "Updating $id on $volume \n"
            synopkg install_from_server "$id" "/$volume"
            #echo "synopkg install_from_server \"$id\" \"/$volume\""  # debug
        else
            echo -e "Updating $id \n"
            synopkg install_from_server "$id"
            #echo "synopkg install_from_server \"$id\""  # debug
        fi
    fi

    fnum=$((fnum +1))
    count=$((count +1))
done

echo -e "\nFinished"

exit
