#!/bin/env tclsh

set appname "PyCharm Educational Edition"
set appurl "https://www.jetbrains.com/pycharm-educational"
set appdesc "a intelligent Python IDE (educational edition)"

## load oracle JDK
if { [ module-info mode load ] } {
    if { ! [is-loaded jdk] } {
        module load jdk
    }
}

## require $version varaible to be set
module-whatis [WhatIs]
prepend-path PATH "$env(DCCN_OPT_DIR)/pycharm/edu/$version/bin"
