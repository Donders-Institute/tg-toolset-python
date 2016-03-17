#!/bin/env tclsh

set appname Blender 
set appurl "http://www.blender.org/" 
set appdesc "A professional free and open-source 3D computer graphics software product" 

## require $version varaible to be set
module-whatis [WhatIs] 
prepend-path PATH "$env(DCCN_OPT_DIR)/blender/${version}"
prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/blender/${version}/lib"
