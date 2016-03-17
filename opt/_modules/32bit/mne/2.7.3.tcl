#!/bin/env tclsh
setenv MNE_LIB_PATH $env(MNE_ROOT)/lib
setenv XUSERFILESEARCHPATH $env(MNE_ROOT)/share/app-defaults/%N
setenv MNE_BIN_PATH $env(MNE_ROOT)/bin
prepend-path LD_LIBRARY_PATH $env(MNE_ROOT)/lib
