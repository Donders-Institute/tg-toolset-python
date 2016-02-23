#!/bin/env tclsh

set appname "Anaconda"
set appurl "http://continuum.io/" 
set appdesc "A python-based ecosystem for scientific and numerical computations"

conflict anaconda

## require $version varaible to be set
module-whatis [WhatIs]
setenv PYTHONHOME $env(DCCN_OPT_DIR)/anaconda/$version
prepend-path PATH "$env(PYTHONHOME)/bin"
