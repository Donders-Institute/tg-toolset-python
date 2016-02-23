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
        module load matlab
        module load freesurfer
        module load mne/${version}
 
        echo "#!/bin/env tclsh" > $output
 
        #${DCCN_MOD_DIR}/share/env2 -from bash -to modulecmd $MNE_ROOT/bin/mne_setup_sh >> $output
        ${DCCN_MOD_DIR}/share/env2 -from bash -to modulecmd $MNE_ROOT/bin/mne_setup_sh | sed -e 's/{\(\S\+\)};/\1/g' | sed "s:${MNE_ROOT}:\$env\(MNE_ROOT\):g" >> $output
 
        module unload mne/${version}
        module unload matlab
        module unload freesurfer
    fi
done
