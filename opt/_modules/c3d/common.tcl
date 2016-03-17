#!/bin/env tclsh

set appname Convert3D
set appurl "http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Documentation" 
set appdesc "a command-line tool for converting 3D images between common file formats." 

## require $version varaible to be set
module-whatis [WhatIs]

prepend-path PATH "$env(DCCN_OPT_DIR)/c3d/${version}/bin"
prepend-path PATH "$env(DCCN_OPT_DIR)/c3d/${version}/lib/c3d_gui-1.0.0"
prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/c3d/${version}/lib/c3d_gui-1.0.0"
