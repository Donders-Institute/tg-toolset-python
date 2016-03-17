#!/bin/env tclsh

set appname FreeSurfer
set appurl "http://freesurfer.net/" 
set appdesc "a brain imaging software package for MRI data analysis" 

## require $version varaible to be set
module-whatis [WhatIs]
setenv FREESURFER_HOME $env(DCCN_OPT_DIR)/freesurfer/$version

## load freesurfer specific setup converted from
## ${FREESURFER_HOME}/SetUpFreeSurfer.sh
set app_setup $env(DCCN_MOD_DIR)/freesurfer/${version}.tcl
if { [file exists $app_setup] } {
    source $app_setup
}
