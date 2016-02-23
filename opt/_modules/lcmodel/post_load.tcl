#!/bin/env tclsh

# create $HOME/.lcmodel directory
if { [file exists $env(HOME)/.lcmodel] == 0 } {
    puts stderr "creating $env(HOME)/.lcmodel ..."
    file mkdir $env(HOME)/.lcmodel
}

foreach tf [glob $env(LCMODEL_HOME)/*] {
   set sf $env(HOME)/.lcmodel/[file tail $tf]
   if { [file exists $sf] == 0 } {
       puts stderr "linking $tf to $sf ..."
       file link -symbolic $sf $tf
   }
}
