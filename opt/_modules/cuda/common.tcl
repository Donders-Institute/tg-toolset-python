#!/bin/env tclsh

set appname "CUDA GPU library"
set appurl "https://developer.nvidia.com/cuda-gpus" 
set appdesc "parallel computing library for NVIDIA GPUs"

## require $version varaible to be set
module-whatis [WhatIs]

if { "$arch" == "linux_x86_64" } {
    prepend-path LD_LIBRARY_PATH "$env(DCCN_OPT_DIR)/cuda/$version/lib64"
    prepend-path PATH "$env(DCCN_OPT_DIR)/cuda/$version/bin"
} else {
    puts stderr "ERROR: $arch not supported"
}
