#!/bin/env tclsh

set appname CMake
set appurl "http://www.cmake.org/" 
set appdesc "CMake is an extensible, open-source system that manages the build process in an operating system and in a compiler-independent manner." 

## require $version varaible to be set
module-whatis [WhatIs]
prepend-path PATH "$env(DCCN_OPT_DIR)/cmake/$version/bin"
