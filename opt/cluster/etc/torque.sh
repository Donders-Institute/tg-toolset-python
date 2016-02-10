#!/bin/sh

# this setting is required for torque
export TORQUEHOME=/var/spool/torque

# add teh path for torque and maui
export MAUIHOMEDIR=/usr/local/maui
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MAUIHOMEDIR/lib
export PATH=$PATH:$MAUIHOMEDIR/bin:$MAUIHOMEDIR/sbin

