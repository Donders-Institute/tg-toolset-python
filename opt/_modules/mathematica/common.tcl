#!/bin/env tclsh

set appname Mathematica 
set appurl  "http://www.wolfram.com/mathematica/" 
set appdesc "a computational software program used in many scientific, engineering, mathematical and computing fields, based on symbolic mathematics"

## require $version varaible to be set
module-whatis [WhatIs] 
prepend-path PATH "$env(DCCN_OPT_DIR)/mathematica/$version/Executables"
