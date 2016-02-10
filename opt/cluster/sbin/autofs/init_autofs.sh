#!/bin/bash

##############################################
# This script should just be run once to
# initalise the autofs service and the top-level
# configuration files.
#
# Additional mounting points should just be
# edit in /opt/cluster/system-files/auto.*
#
##############################################

function get_script_dir() {
    ## resolve the base directory of this executable
    local SOURCE=$1
    while [ -h "$SOURCE" ]; do
        # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"

        # if $SOURCE was a relative symlink,
        # we need to resolve it relative to the path
        # where the symlink file was located

        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

if [ ! -d /etc/auto.master.d ]; then
    mkdir -p /etc/auto.master.d
fi

basedir=`get_script_dir $0`

for f in `ls --color=never $basedir/*.autofs`; do 
    cp $f /etc/auto.master.d
done

systemctl enable autofs
systemctl start autofs
