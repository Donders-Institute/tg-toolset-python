#!/bin/env tclsh
setenv COMPILERDIR $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046
setenv MKLPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/lib/em64t
prepend-path PATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/bin/intel64
setenv INCLUDE $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/include
setenv INTEL_LICENSE_FILE $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/licenses:/opt/intel/licenses:/root/intel/licenses
setenv IFORTDIR $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/bin/intel64
setenv CPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/include
setenv FPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/include
prepend-path LD_LIBRARY_PATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/lib/em64t
prepend-path LD_LIBRARY_PATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/lib/intel64
prepend-path MANPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/man/en_US
prepend-path MANPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/man/en_US
setenv LIBRARY_PATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/lib/intel64:$env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/lib/em64t
setenv MKLROOT $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl
setenv NLSPATH $env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/lib/intel64/locale/%l_%t/%N:$env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/mkl/lib/em64t/locale/%l_%t/%N:$env(NEUROSIM_ROOT)/intel/Compiler/11.1/046/idb/intel64/locale/%l_%t/%N
