#!/bin/bash

if [ $USER != 'ceph' ]; then
    echo "run it with ceph account"
    exit 1
fi

cat << EOF

In the following ssh-keygen command, leave the passphrase to empty.

EOF

ssh-keygen

for node in "$@"; do
    echo "deploy to ceph@$node ..."
    ssh-copy-id ceph@$node
done
