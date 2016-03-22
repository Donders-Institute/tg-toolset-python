#!/bin/env tclsh

set appname "ANTs"
set appurl  "http://stnava.github.io/ANTs/" 
set appdesc "Advanced Normalization Tools for managing, interpreting and visualizing multidimensional data" 

## require $version varaible to be set
module-whatis [WhatIs]
if { [ module-info mode load ] } {
    if { [is-loaded itk] } {
        module unload itk 
    }
}
setenv NSLOTS 1
setenv ANTSPATH "$env(DCCN_OPT_DIR)/ANTs/$version/build/bin"
prepend-path PATH "$env(DCCN_OPT_DIR)/ANTs/$version/build/bin"