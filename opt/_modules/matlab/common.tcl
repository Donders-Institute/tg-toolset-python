#!/bin/env tclsh

set appname Matlab
set appurl "http://www.mathworks.nl/products/matlab/"
set appdesc "a high-level language and interactive environment for numerical computation, visualization, and programming"

module-whatis [WhatIs]

setenv MATLABDIR "$env(DCCN_OPT_DIR)/matlab/$version"

# prepend-path PATH "$env(MATLABDIR)/bin"

setenv MATLAB_BIN "$env(MATLABDIR)/bin/matlab"

# also load the cluster module to get 'matlabXX' available
if { ! [ module-info mode whatis ] } {
    if { ! [is-loaded cluster] } {
        module load cluster
    }
}

#set-alias matlab matlabXX
set-alias matlab-torque matlabXX-torque
set-alias matlab-noX11tunnel matlabXX-noX11tunnel
