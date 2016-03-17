#!/bin/env tclsh

set appname MNE 
set appurl "http://martinos.org/mne/stable/index.html" 
set appdesc "a software package for processing MEG and EEG data" 

## require $version varaible to be set
module-whatis [WhatIs]

setenv MNE_ROOT "$env(DCCN_32_DIR)/mne/$version"
prepend-path PATH "$env(DCCN_32_DIR)/mne/$version/bin"

## load MNE specific setup converted from
## ${MNE_ROOT}/bin/mne_setup_sh
set app_setup $env(DCCN_MOD_DIR)/mne/${version}.tcl
if { [file exists $app_setup] } {
    source $app_setup
}
