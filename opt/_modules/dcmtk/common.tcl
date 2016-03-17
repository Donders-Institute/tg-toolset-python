#!/bin/env tclsh

set appname "DCMTK"
set appurl "http://dicom.offis.de/dcmtk.php.en" 
set appdesc "a collection of libraries and applications implementing large parts the DICOM standard" 

module-whatis [WhatIs]

setenv DCMDICTPATH $env(DCCN_OPT_DIR)/dcmtk/$version/share/dcmtk/dicom.dic 
prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/dcmtk/$version/lib"
prepend-path PATH "$env(DCCN_OPT_DIR)/dcmtk/$version/bin"
prepend-path MANPATH "$env(DCCN_OPT_DIR)/dcmtk/$version/share/man"
