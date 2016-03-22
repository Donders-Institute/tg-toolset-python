#!/bin/env tclsh

set appname FSL
set appurl "http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/" 
set appdesc "a software library containing image analysis and statistical tools for functional, structural and diffusion MRI brain imaging data"

module-whatis [WhatIs]

## make sure only one fsl is loaded at a time
if { [ module-info mode load ] } {
    if { [is-loaded fsl] && ! [is-loaded fsl/$version] } {
        module unload fsl
    }
}

setenv FSLDIR $env(DCCN_OPT_DIR)/fsl/$version
prepend-path PATH "$env(FSLDIR)/bin"

## load freesurfer specific setup converted from
## ${FSLDIR}/etc/fslconf/fsl.sh
set app_setup $env(DCCN_MOD_DIR)/fsl/${version}.tcl
if { [file exists $app_setup] } {
    source $app_setup
}