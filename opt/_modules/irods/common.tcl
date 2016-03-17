#!/bin/env tclsh

set appname iRODS 
set appurl "http://irods.org/" 
set appdesc "The client component of the Integrated Rule-Oriented Data System" 

## require $version varaible to be set
module-whatis [WhatIs] 
setenv IRODS_PLUGINS_HOME "$env(DCCN_OPT_DIR)/irods/$version/centos$os_version/lib/plugins/"
prepend-path PATH "$env(DCCN_OPT_DIR)/irods/$version/centos$os_version/bin"
prepend-path MANPATH "$env(DCCN_OPT_DIR)/irods/$version/man"

## copy over or update the irods_environment.json file to user's ~/.irods directory
if { [ module-info mode load ] } {
    set irods_env_template $env(DCCN_OPT_DIR)/irods/$version/centos$os_version/irods_environment.json
    set irods_env_user $env(HOME)/.irods/irods_environment.json

    if { [ file exists $irods_env_template ] == 1 } {

        if { [ file exists $irods_env_user ] == 0 } {
            # make sure $env(HOME)/.irods exists
            file mkdir $env(HOME)/.irods
         
            # copy the irods_environment template to $env(HOME)/.irods
            file copy -force $irods_env_template $irods_env_user
        }
    }
}
