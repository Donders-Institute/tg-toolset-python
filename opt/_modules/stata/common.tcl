#!/bin/env tclsh

set appname Stata 
set appurl "http://www.stata.com/" 
set appdesc "a general-purpose statistical software package" 

## require $version varaible to be set
module-whatis [WhatIs] 

set stata_root "$env(DCCN_OPT_DIR)/stata/$version"

prepend-path PATH "$stata_root"
prepend-path PATH "$stata_root/cmds"

#set-alias stata "$stata_root/xstata"
#set-alias stata-noX "$stata_root/stata"
#set-alias stata-se "$stata_root/xstata-se"
#set-alias stata-se-noX "$stata_root/stata-se"
