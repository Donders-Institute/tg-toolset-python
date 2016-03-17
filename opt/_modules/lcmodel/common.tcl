#!/bin/env tclsh

set appname LCModel
set appurl "http://www.s-provencher.com/pages/lcmodel.shtml" 
set appdesc "Tool for the automatic quantitation of in vivo proton MR spectra" 

## require $version varaible to be set
module-whatis [WhatIs] 
setenv LCMODEL_HOME $env(DCCN_OPT_DIR)/lcmodel/$version
prepend-path PATH "$env(HOME)/.lcmodel/bin"

## run post scripts for module load and unload 
if { [ module-info mode load ] } {
    source $env(DCCN_MOD_DIR)/lcmodel/post_load.tcl
} elseif { [ module-info mode remove ] } {
    source $env(DCCN_MOD_DIR)/lcmodel/post_unload.tcl
} else { }
