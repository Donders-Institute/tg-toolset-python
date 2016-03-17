#!/bin/env tclsh

# remove symbolic links to software repository
foreach tf [glob $env(LCMODEL_HOME)/*] {
   set sf $env(HOME)/.lcmodel/[file tail $tf]
   if { [file exists $sf] == 1 && [string match "link" [file type $sf]] } {
       puts stderr "unlinking $sf ..."
       file delete $sf
   }
}
