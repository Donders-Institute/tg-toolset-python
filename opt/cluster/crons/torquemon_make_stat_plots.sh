#!/bin/bash
#
# Wrapper script for cron job to call "Rscript plotter.R"
#

opt_dir=$1
db_topdir=$2
m=`date +%Y%m`

source /cvmfs/dccn.nl/setup.sh
module load R/3.0.3
tool_dir=$opt_dir/cluster/external/cluster_monitor/stat

## The following code is more consistent; but it requires the $opt_dir to be /opt for R to work
#source $opt_dir/_modules/setup.sh
#module load cluster
#module load R/3.1.2
#tool_dir=$CLUSTER_UTIL_ROOT/external/cluster_monitor/stat

Rscript $tool_dir/R/job_statistics/plotter.R $db_topdir $m

# make evolution plots for the last 6 months
Rscript $tool_dir/R/job_statistics/evolution.R $db_topdir 12
