#!/bin/env tclsh

set appname afni
set appurl "http://afni.nimh.nih.gov/" 
set appdesc "Free software for analysis and display of FMRI data" 

## require $version varaible to be set
module-whatis [WhatIs]
setenv AFNI_HOME $env(DCCN_OPT_DIR)/afni/$version
prepend-path PATH "$env(AFNI_HOME)/" 

