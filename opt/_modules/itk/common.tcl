#!/bin/env tclsh

set appname "ITK"
set appurl  "http://www.itk.org/" 
set appdesc "Insight Segmentation and Registration Toolkit" 

## require $version varaible to be set
module-whatis [WhatIs]
setenv ITK_DIR "$env(DCCN_OPT_DIR)/itk/$version/build"
prepend-path PATH "$env(ITK_DIR)/bin"
