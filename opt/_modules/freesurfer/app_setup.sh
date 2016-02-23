#!/bin/bash

if [ $# -lt 1 ]; then
    echo "usage: $0 ver1 [ver2] [...]"
    exit 1
fi

source ${DCCN_MOD_DIR}/setup.sh
source ${DCCN_MOD_DIR}/share/common.sh
DIR=$( get_script_dir ${BASH_SOURCE[0]} )

## purge all loaded modules to start with a clean(vanilla) environment
module purge
for version in "$@"; do

    output=${DIR}/${version}.tcl

    if [ -f $output ]; then
        echo "$output exists, skip the convertion"
    else
        module load freesurfer/${version}
 
        echo "#!/bin/env tclsh" > $output
 
        #${DCCN_MOD_DIR}/share/env2 -from bash -to modulecmd $FREESURFER_HOME/SetUpFreeSurfer.sh >> $output
        ${DCCN_MOD_DIR}/share/env2 -from bash -to modulecmd $FREESURFER_HOME/SetUpFreeSurfer.sh | sed -e 's/{\(\S\+\)};/\1/g' | sed "s:${FREESURFER_HOME}:\$env\(FREESURFER_HOME\):g" >> $output
 
        module unload freesurfer/${version}
    fi
done
