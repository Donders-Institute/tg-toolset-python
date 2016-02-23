#!/bin/env tclsh

set appname "DICOM Anonymizer Pro" 
set appurl "https://www.neologica.it/eng/Products/DICOMAnonymizerPro" 
set appdesc "A tool for removing personal identifying information from the header of DICOM image files, as well as from any other kind of DICOM datasets."

## require $version varaible to be set
module-whatis [WhatIs]

prepend-path PATH "$env(DCCN_OPT_DIR)/dicom-anonymizer-pro/$version"
