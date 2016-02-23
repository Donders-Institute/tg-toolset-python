#!/bin/env tclsh

set appname "Oracle JDK"
set appurl "http://www.oracle.com/technetwork/java/javase/overview/index.html"
set appdesc "The Oracle version of Java SE Development Kit"

## require $version varaible to be set
module-whatis [WhatIs]
setenv JAVA_HOME "$env(DCCN_OPT_DIR)/jdk/$version"
prepend-path PATH "$env(JAVA_HOME)/bin"
