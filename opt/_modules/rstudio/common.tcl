#!/bin/env tclsh

set appname rstudio
set appurl "http://www.rstudio.com/" 
set appdesc "a free integrated development environment (IDE) for R" 

## require $version varaible to be set
module-whatis [WhatIs] 
setenv R_HOME $env(DCCN_OPT_DIR)/R/3.2.0/
setenv R_LIBS $env(DCCN_OPT_DIR)/R/packages
setenv RSTUDIO $env(DCCN_OPT_DIR)/rstudio/$version/
unsetenv SESSION_MANAGER
prepend-path PATH "$env(R_HOME)/bin"
prepend-path MANPATH "$env(R_HOME)/share/man"
prepend-path LD_LIBRARY_PATH "$env(R_HOME)/lib"
prepend-path PATH "$env(DCCN_OPT_DIR)/rstudio/$version/bin"
