#!/bin/env tclsh

set appname "Open MPI"
set appurl "http://www.open-mpi.org/" 
set appdesc "A High Performance Message Passing Library"

## require $version varaible to be set
module-whatis [WhatIs]
setenv MPIHOME $env(DCCN_OPT_DIR)/openmpi/$version
prepend-path PATH "$env(MPIHOME)/bin"
