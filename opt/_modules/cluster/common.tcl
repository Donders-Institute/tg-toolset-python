#!/bin/env tclsh

set appname "HPC cluster utilities" 
set appurl  ""
set appdesc "a collection of home-grown cluster utilities/scripts"

## require $version varaible to be set
module-whatis [WhatIs]
setenv CLUSTER_UTIL_ROOT $env(DCCN_OPT_DIR)/cluster
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/sbin"
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/bin"
prepend-path MANPATH "$env(CLUSTER_UTIL_ROOT)/man"

# add the utility binaries and libraries
if { $arch == "linux_x86_64" } {
    prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/utilities/bin64"
    prepend-path LD_LIBRARY_PATH "$env(CLUSTER_UTIL_ROOT)/lib"
} else {
    prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/utilities/bin32"
}
append-path MANPATH "$env(CLUSTER_UTIL_ROOT)/external/utilities/man"

# add external tools included as part of the cluster package
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/cluster_monitor"
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/project_acl"
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/keepassx/latest/bin"
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/rdm-irods-utility/bin/export"

# add the path for torque and maui/moab
setenv TORQUEHOME /var/spool/torque

#setenv MAUIHOMEDIR /usr/local/maui
#append-path LD_LIBRARY_PATH $env(MAUIHOMEDIR)/lib
#append-path PATH $env(MAUIHOMEDIR)/bin
#append-path PATH $env(MAUIHOMEDIR)/sbin

setenv MOABHOMEDIR "$env(CLUSTER_UTIL_ROOT)/external/moab"
prepend-path PATH "$env(CLUSTER_UTIL_ROOT)/external/moab/bin"
prepend-path MANPATH "$env(CLUSTER_UTIL_ROOT)/external/moab/share/man"

set-alias boxes "boxes -f $env(CLUSTER_UTIL_ROOT)/etc/boxes-config"
