#!/bin/bash

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

module load python
dir=$( get_script_dir $0 )

export IRDM_PREFIX=$( cd -P $dir/.. && pwd )

ipythondir=$HOME/.ipython-irdm

## the ipython dir is never created
if [ ! -d $ipythondir ]; then
    mkdir -p $ipythondir/profile_default/startup
fi

## install the startup function
for f in $( ls ${IRDM_PREFIX}/[0-9][0-9]-*.py ); do
    cp $f ${ipythondir}/profile_default/startup
done

## install the preload function
cp ${IRDM_PREFIX}/preload.ipy $ipythondir

config=${IRDM_PREFIX}/rdm.py

ipython --ipython-dir=$ipythondir --config=$config
