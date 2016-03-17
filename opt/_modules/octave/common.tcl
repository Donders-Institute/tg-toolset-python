#!/bin/env tclsh

set appname "GNU Octave"
set appurl "http://www.gnu.org/software/octave/" 
set appdesc "A high-level interpreted language, primarily intended for numerical computations" 

module-whatis [WhatIs]

prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/octave/$version/lib/octave/$version"
prepend-path PATH "$env(DCCN_OPT_DIR)/octave/$version/bin"
