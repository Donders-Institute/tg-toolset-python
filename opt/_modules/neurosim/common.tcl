#!/bin/env tclsh

set appname "Neurosim" 
set appurl "http://" 
set appdesc "" 

## require $version varaible to be set
module-whatis [WhatIs] 

setenv NEUROSIM_ROOT   $env(DCCN_OPT_DIR)/neurosim/$version
prepend-path PATH "$env(NEUROSIM_ROOT)/Runscripts"
prepend-path PATH "$env(NEUROSIM_ROOT)/Compilescripts"

## load Intel compiler specific setup converted from
## ${NEUROSIM_ROOT}/env_intel-MKL.sh
set app_setup $env(DCCN_MOD_DIR)/neurosim/${version}.tcl
if { [file exists $app_setup] } {
    source $app_setup
}
