#!/bin/env tclsh

set appname R
set appurl "http://www.r-project.org/" 
set appdesc "a free software programming language and software environment for statistical computing and graphics" 

## require $version varaible to be set
module-whatis [WhatIs] 
setenv R_HOME $env(DCCN_OPT_DIR)/R/$version
prepend-path PATH "$env(R_HOME)/bin"
prepend-path MANPATH "$env(R_HOME)/share/man"
prepend-path LD_LIBRARY_PATH "$env(R_HOME)/lib64"

## The shared package libraries are built with libR.so (the shared library of R)
## and thus it's not compatible with earlier R versions that are built into static library.
if { $version ni {"3.1.2"} } {
    append-path  R_LIBS "$env(DCCN_OPT_DIR)/R/packages"
}
