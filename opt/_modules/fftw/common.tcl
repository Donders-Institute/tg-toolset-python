#!/bin/env tclsh

set appname "FFTW"
set appurl "http://www.fftw.org" 
set appdesc "fast Fourier transform library" 

module-whatis [WhatIs]

prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/fftw/$version/lib"
prepend-path PATH "$env(DCCN_OPT_DIR)/fftw/$version/bin"
