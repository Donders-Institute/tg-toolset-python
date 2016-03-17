#!/bin/env tclsh

set appname MRIcro
set appurl "http://www.mccauslandcenter.sc.edu/mricro/"
set appdesc "a lightweight utility for visualizing MRI data"

## require $version varaible to be set
module-whatis [WhatIs]
prepend-path PATH "$env(DCCN_OPT_DIR)/mricro/$version"
