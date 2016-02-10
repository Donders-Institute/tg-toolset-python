#!/bin/bash

logdir="/project/3010000.01/storage_usage"

today=$( date +%Y-%m-%d )
ssh admin@filer-a-mi 'volume show -vserver atreides -fields size,used,available' | grep 'atreides' | awk '{print $2,$3,$4,$5}' | gzip > ${logdir}/${today}.log.gz
