## Encountered issues

 - On CentOS6, the redhat-lsb-4.0-3 conflicts with redhat-lsb-4.0-7 the ceph-deploy tries to install. One should remove it manually before calling ceph-deploy install.

## Strange construction for preparing OSD

 - I used btrfs to group HDDs into one big disk and mount it to /var/lib/ceph/osd
 - but for Journal, I let the ceph-deploy to create it on SSD
 - the overall command to prepare OSD is something like

   ```bash
   $ ceph-deploy --overwrite-conf osd prepare --fs-type btrfs dccn-c035:/var/lib/ceph/osd:/dev/sdb
   ```

   where the size of journal can be specified in ceph.conf file.

 - when start over the partioning, one should clean up the file in /var/lib/ceph/osd and use `ceph-deploy disk zap HOST:DISK` to get rid of existing partitions for the journal on SSD

## configuration file deploy

 - eveytime the configuraiton changed on admin node, using the following commands to deploy the new configuration to all ceph nodes

   ```bash
   $ ceph-deploy --overwrite-conf config push HOST1 HOST2 ...
   ```
