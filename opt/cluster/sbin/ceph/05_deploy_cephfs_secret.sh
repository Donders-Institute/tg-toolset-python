#!/bin/bash

secret=$1

cmd="echo $secret"

for h in ${@:2}; do
    ssh -tt ceph@$h "echo $secret | sudo tee /etc/ceph/cephfs.secret"
done
