#!/bin/env tclsh

set appname ITK-SNAP
set appurl "http://www.itksnap.org/pmwiki/pmwiki.php" 
set appdesc "a software application used to segment structures in 3D medical images" 

## require $version varaible to be set
module-whatis [WhatIs]

setenv ITK_SNAP_ROOT "$env(DCCN_OPT_DIR)/itk-snap/${version}"

prepend-path PATH "$env(ITK_SNAP_ROOT)/bin"
