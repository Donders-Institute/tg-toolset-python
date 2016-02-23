#!/bin/env tclsh

set appname MRIcron
set appurl "http://www.mccauslandcenter.sc.edu/mricro/mricron/index.html" 
set appdesc "a cross-platform NIfTI format image viewer"

## require $version varaible to be set
module-whatis [WhatIs] 
prepend-path PATH "$env(DCCN_OPT_DIR)/mricron/$version"
