#!/bin/env tclsh

set appname "Matlab Compiler Runtime" 
set appurl "http://www.mathworks.nl/products/compiler/mcr/" 
set appdesc "a standalone set of shared libraries that enables the execution of compiled MATLAB applications or components on computers that do not have MATLAB installed" 

## require $version varaible to be set
module-whatis [WhatIs] 

set mcr_home   $env(DCCN_OPT_DIR)/MCR/$version/$arch

if { "$arch" == "linux_x86_64" } then {
    set java_home  $mcr_home/sys/java/jre/glnxa64
    prepend-path LD_LIBRARY_PATH "$java_home/jre/lib/amd64"
    prepend-path LD_LIBRARY_PATH "$java_home/jre/lib/amd64/server"
    prepend-path LD_LIBRARY_PATH "$java_home/jre/lib/amd64/native_threads"
    prepend-path LD_LIBRARY_PATH "$mcr_home/sys/os/glnxa64"
    prepend-path LD_LIBRARY_PATH "$mcr_home/runtime/glnxa64"
    prepend-path LD_LIBRARY_PATH "$mcr_home/bin/glnxa64"

    prepend-path XAPPLRESDIR "$mcr_home/X11/app-defaults"

    if [info exists env(TMPDIR)] {
        setenv MCR_CACHE_ROOT $env(TMPDIR)
    } else {
        setenv MCR_CACHE_ROOT "/tmp"
    }
} else {
    puts stderr "\n\tVersion $version does not support archtecture $arch.\n"
}
