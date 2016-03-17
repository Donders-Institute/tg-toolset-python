#!/bin/env tclsh

set appname EAGLE
set appurl "http://www.cadsoftusa.com/" 

## require $version varaible to be set
module-whatis [WhatIs] 

prepend-path PATH "$env(DCCN_32_DIR)/eagle/$version/bin"
