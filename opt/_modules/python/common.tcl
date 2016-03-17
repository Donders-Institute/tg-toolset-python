#!/bin/env tclsh

set appname "Python"
set appurl "https://www.python.org/" 
set appdesc "a general purpose, high-level programming language"

conflict python

## require $version varaible to be set
module-whatis [WhatIs]
setenv PYTHONHOME $env(DCCN_OPT_DIR)/python/$version
prepend-path PATH "$env(PYTHONHOME)/bin"
