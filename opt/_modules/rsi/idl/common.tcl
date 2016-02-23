#!/bin/env tclsh

set appname IDL 
set appurl "http://www.exelisvis.com/ProductsServices/IDL.aspx" 
set appdesc "Interactive Data Language, a programming language used for data analysis and visualisation"

## require $version varaible to be set
module-whatis [WhatIs] 

setenv IDL_DIR $env(DCCN_OPT_DIR)/rsi/idl/${version}
setenv LM_LICENSE_FILE "1700@fcdc006s"
prepend-path PATH $env(IDL_DIR)/bin
