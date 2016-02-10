#!/bin/bash

ceph_mon=$1
mount_pt=$2

for h in ${@:3}; do
    ssh -tt ceph@$h "sudo mkdir -p $mount_pt"
    ssh -tt ceph@$h "sudo mount -t ceph ${ceph_mon}:/ $mount_pt -o name=cephfs,secretfile=/etc/ceph/cephfs.secret"
done
