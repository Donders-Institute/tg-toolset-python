#!/bin/env tclsh
setenv DYLD_LIBRARY_PATH $env(FREESURFER_HOME)/lib/tcltktixblt/lib:$env(FREESURFER_HOME)/lib/gsl/lib:$env(FREESURFER_HOME)/lib/
setenv FSLOUTPUTTYPE NIFTI_GZ
setenv FMRI_ANALYSIS_DIR $env(FREESURFER_HOME)/fsfast
setenv FSLLOCKDIR {};
setenv FSLMACHINELIST {};
prepend-path PATH $env(FREESURFER_HOME)/mni/bin
prepend-path PATH $env(FREESURFER_HOME)/lib/gsl/bin
prepend-path PATH /usr/lib64/qt-3.3/bin
prepend-path PATH $env(FREESURFER_HOME)/lib/tcltktixblt/bin
prepend-path PATH $env(FREESURFER_HOME)/fsl/bin
prepend-path PATH $env(FREESURFER_HOME)/bin
prepend-path PATH $env(FREESURFER_HOME)/bin/noarch
prepend-path PATH $env(FREESURFER_HOME)/fsfast/bin
setenv BLT_LIBRARY $env(FREESURFER_HOME)/lib/tcltktixblt/lib/blt2.4
setenv SUBJECTS_DIR $env(FREESURFER_HOME)/subjects
setenv MNI_DATAPATH $env(FREESURFER_HOME)/mni/data
setenv MINC_BIN_DIR $env(FREESURFER_HOME)/mni/bin
setenv FSFAST_HOME $env(FREESURFER_HOME)/fsfast
setenv FSLGNUPLOT $env(FREESURFER_HOME)/fsl/bin/gnuplot
setenv FSLWISH $env(FREESURFER_HOME)/fsl/bin/wish
setenv FSLTCLSH $env(FREESURFER_HOME)/fsl/bin/tclsh
setenv FSLMULTIFILEQUIT TRUE
setenv FSLREMOTECALL {};
setenv TK_LIBRARY $env(FREESURFER_HOME)/lib/tcltktixblt/lib/tk8.4
setenv LOCAL_DIR $env(FREESURFER_HOME)/local
setenv FSLMACHTYPE x86_64-redhat-linux-gcc4.4.7
setenv FS_OVERRIDE 0
setenv OS Linux
setenv TCL_LIBRARY $env(FREESURFER_HOME)/lib/tcltktixblt/lib/tcl8.4
setenv FSLBROWSER $env(FREESURFER_HOME)/fsl/tcl/fslwebbrowser
setenv FSL_BIN $env(FREESURFER_HOME)/fsl/bin
setenv PERL5LIB $env(FREESURFER_HOME)/mni/lib/perl5/5.8.5
setenv FSLDIR $env(FREESURFER_HOME)/fsl
setenv MINC_LIB_DIR $env(FREESURFER_HOME)/mni/lib
setenv LD_LIBRARY_PATH $env(FREESURFER_HOME)/lib/tcltktixblt/lib:/usr/lib64/qt-3.3/lib:$env(FREESURFER_HOME)/lib/gsl/lib:$env(FREESURFER_HOME)/mni/lib:$env(FREESURFER_HOME)/lib/
setenv TIX_LIBRARY $env(FREESURFER_HOME)/lib/tcltktixblt/lib/tix8.1
setenv GSL_DIR $env(FREESURFER_HOME)/lib/gsl
setenv FSL_DIR $env(FREESURFER_HOME)/fsl
setenv TCLLIBPATH $env(FREESURFER_HOME)/lib/tcltktixblt/lib
setenv FSLDISPLAY $env(FREESURFER_HOME)/fsl/bin/display
setenv FSLCONVERT $env(FREESURFER_HOME)/fsl/bin/convert
setenv FUNCTIONALS_DIR $env(FREESURFER_HOME)/sessions
setenv FSLCONFDIR $env(FREESURFER_HOME)/fsl/config
