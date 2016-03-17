#!/bin/env tclsh

set appname OpenMEEG
set appurl "http://openmeeg.github.io/" 
set appdesc "a C++ package for low-frequency bio-electromagnetism solving forward problems in the field of EEG and MEG"

## require $version varaible to be set
module-whatis [WhatIs] 

prepend-path PATH "$env(DCCN_OPT_DIR)/openmeeg/$version/bin"
prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/openmeeg/$version/lib"
