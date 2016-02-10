#!/bin/bash

opt_dir=$1

source $opt_dir/_modules/setup.sh

module load cluster
module load anaconda/2.7

tool_dir=$CLUSTER_UTIL_ROOT/external/cluster_monitor/stat

$tool_dir/mm_trackTorqueJobs.py -l 1 -a -m -c $tool_dir/etc/config_mgr.ini
