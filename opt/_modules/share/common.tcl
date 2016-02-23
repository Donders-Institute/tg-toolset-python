#!/bin/env tclsh

## determin system architecture
proc get_sys_arch { }  {
    set arch [exec uname -m]
    if { "$arch" == "x86_64" } then {
        set my_arch "linux_x86_64"
    } else {
        set my_arch "linux_i686"
    }

    return $my_arch
}

## determin centos version
proc get_redhat_version { }  {
    regexp {^(\S+)[\s,[:alpha:]]*([0-9,\.]+).*} [exec cat /etc/redhat-release] matched os_name os_version

    return $os_version 
}

## ensure only one version at a time
proc force_one_version { } {

    global version

    set module_name [file dirname [module-info name]]
  
    if { [ module-info mode load ] } {
        if { [is-loaded $module_name] && ! [is-loaded $module_name/$version] } {
            module unload $module_name
        }
    }
}

## common ModulesHelp function
proc ModulesHelp { } {
    global appname appurl version arch

    puts stderr "\tSet up the environment for $appname"
    puts stderr "\n\tVersion $version Archtecture $arch."
    puts stderr "\n\tWebsite: $appurl\n"
}

## common WhatIs function
proc WhatIs { } {
    global appname appurl docurl appdesc

    ## set default appurl if not specified
    if { ! [info exists appurl] } {
        set appurl ""
    }

    ## set empty docurl
    if { ! [info exists docurl] } {
        set docurl ""
    }

    ## set empty appdesc 
    if { ! [info exists appdesc] } {
        set appdesc ""
    }

    return "|$appname|$appurl|$docurl|$appdesc|"
}
