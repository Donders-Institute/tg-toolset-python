#!/bin/env tclsh

set appname Caret
set appurl "http://brainvis.wustl.edu/wiki/index.php/Caret:About" 
set appdesc "a free, open-source, software package for structural and functional analyses of the cerebral and cerebellar cortex"

## require $version varaible to be set
module-whatis [WhatIs] 
prepend-path PATH "$env(DCCN_OPT_DIR)/caret/$version/bin_linux64"
