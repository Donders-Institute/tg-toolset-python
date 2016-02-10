#!/bin/bash

useradd -d /var/lib/ceph_home -m ceph
passwd ceph

rm -rf /var/lib/ceph/.bash*
rm -rf /var/lib/ceph/.gnome2

echo "ceph ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/ceph
chmod 400 /etc/sudoers.d/ceph

cat << EOF
make sure you have the following line in /etc/sudoers,

    #includedir /etc/sudoers.d

otherwise, add it manually using the visudo command.
EOF

cat << EOF
also, make sure SSH login is allowed for user 'ceph'. Check the file 

    /etc/ssh/sshd_config

EOF
