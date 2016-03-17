#!/bin/env tclsh

set appname BranvoyagerQX
set appurl "http://www.brainvoyager.com/products/brainvoyagerqx.html" 
set appdesc "user friendly software package for the analysis and visualization of functional and structural MRI datasets"

## require $version varaible to be set
module-whatis [WhatIs] 
prepend-path PATH "$env(DCCN_OPT_DIR)/brainvoyagerqx/$version"
