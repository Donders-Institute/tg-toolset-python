#!/bin/env tclsh
setenv FSLOUTPUTTYPE NIFTI_GZ
setenv FSLMACHTYPE x86_64-redhat-linux-gcc4.4.7
setenv FSLBROWSER $env(FSLDIR)/tcl/fslwebbrowser
setenv FSLLOCKDIR {};
setenv FSLMACHINELIST {};
setenv FSLGNUPLOT $env(FSLDIR)/bin/gnuplot
setenv FSLTCLSH $env(FSLDIR)/bin/tclsh
setenv FSLWISH $env(FSLDIR)/bin/wish
setenv FSLMULTIFILEQUIT TRUE
setenv FSLDISPLAY $env(FSLDIR)/bin/display
setenv FSLREMOTECALL {};
setenv FSLCONVERT $env(FSLDIR)/bin/convert
setenv FSLCONFDIR $env(FSLDIR)/config
