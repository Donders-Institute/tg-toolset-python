#!/bin/env tclsh
setenv FSLOUTPUTTYPE NIFTI_GZ
setenv FSLLOCKDIR {};
setenv FSLMACHINELIST {};
setenv FSLGECUDAQ cuda.q
setenv FSLTCLSH $env(FSLDIR)/bin/fsltclsh
setenv FSLWISH $env(FSLDIR)/bin/fslwish
setenv FSLMULTIFILEQUIT TRUE
setenv FSLREMOTECALL {};
