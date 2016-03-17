#!/bin/env tclsh

set appname "CTF MEG software" 
set appurl "http://www.ctfmeg.com/software.html" 
set appdesc "MEG acquisition and analysis software" 

## require $version varaible to be set
module-whatis [WhatIs] 

setenv CTF_DIR $env(DCCN_32_DIR)/ctf/$version

# set unique ctf variables
setenv CTF_TEMPDIR /tmp
setenv CTF_DATADIR $env(HOME)/MEG/subject
setenv CTF_WORKDIR $env(HOME)/MEG/study
setenv CTF_MRIDIR  /home/commmon/meg_mri
setenv CTF_ACQDIR  /data/$env(USER)

# set unique ctf variables
prepend-path PATH $env(CTF_DIR)/bin
prepend-path LD_LIBRARY_PATH $env(CTF_DIR)/lib

# TODO: what is this for?
setenv TESTPATH /opt
