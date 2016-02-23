#!/bin/env tclsh

source common.tcl

# get full version numbering, split by '.' and get the major version number
set os_version [lindex [split [get_redhat_version] "."] 0]

puts $os_version
