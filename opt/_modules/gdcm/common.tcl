#!/bin/env tclsh

set appname "GDCM"
set appurl "http://gdcm.sourceforge.net/" 
set appdesc "Grassroots DICOM library" 

module-whatis [WhatIs]

prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/gdcm/$version/lib"
prepend-path PATH "$env(DCCN_OPT_DIR)/gdcm/$version/bin"
