#!/bin/env tclsh
setenv FSLOUTPUTTYPE NIFTI_GZ
setenv FSLMACHTYPE linux_64-gcc4.4
setenv FSLBROWSER $env(FSLDIR)/tcl/fslwebbrowser
setenv FSLLOCKDIR {};
setenv FSLMACHINELIST {};
setenv FSLTCLSH $env(FSLDIR)/bin/fsltclsh
setenv FSLWISH $env(FSLDIR)/bin/fslwish
setenv FSLMULTIFILEQUIT TRUE
setenv FSLREMOTECALL {};
setenv FSLCONFDIR $env(FSLDIR)/config
