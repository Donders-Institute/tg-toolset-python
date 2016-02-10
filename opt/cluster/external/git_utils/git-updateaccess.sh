#!/bin/bash

## resolve the base directory of this executable
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"

  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

## retrieve user information
uid=`id -un`
uname=`finger $uid | grep 'Name' | awk -F ': ' '{print $NF}'`

pid=$$
cwd=`pwd`
host=`hostname -f`

flog=$cwd/git-updateaccess.$pid.log

## load utility functions
. $DIR/git-functions.sh

function usage {
  echo
  echo "==============================================================="
  echo "Usage: $0 [options] <repo_base_dir> <project_name>"
  echo
  echo "  <repo_base_dir>: top directory in which the GIT repository will be located"
  echo "  <project_name> : GIT project name"
  echo
  echo "options:"
  echo "    -w [user1,user2,...]: give a list of users with read-write permission to the repository"
  echo "    -r [user1,user2,...]: give a list of users with read-only permission to the repository"
  echo "    -x [user1,user2,...]: remove a list of users from the access to the repository"
  echo "    -l                  : keep log file on success. Default: off"
  echo "==============================================================="
  echo
}

## parsing commandline arguments
group=`groups $uid | awk '{print $2}'`
rmlog=1
while getopts "hr:w:x:l" flag
do
  case "$flag" in
    w)
      uwlist=$OPTARG
      ;;
    x)
      uxlist=$OPTARG
      ;;
    r)
      urlist=$OPTARG
      ;;
    l)
      rmlog=0
      ;;
    h|?)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ $# != 2 ]; then
    print_err "missing required user arguments" 0
    usage
    exit 1
fi

## required user arguments
base=$1
proj=$2

## create directory for bare git repository
bare_repo=$base/${proj}.git

echo -ne "--> checking existence of repository directory ... "

if [ ! -d $bare_repo ]; then
    fail
    print_err "directory not existing: $bare_repo" 1
    exit 1
fi

success

## remove user from ACL
if [ ! -z $uxlist ]; then
    update_repo_acl $uxlist "x" $bare_repo
fi

## user ACL for read-write permission
if [ ! -z $uwlist ]; then
    update_repo_acl $uwlist "w" $bare_repo
fi

## user ACL for read-only permission
if [ ! -z $urlist ]; then
    update_repo_acl $urlist "r" $bare_repo
fi

rm -rf $tmpdir >> $flog 2>&1

if [ $rmlog -eq 1 ]; then
    rm -f $flog
else
    echo ""
    echo "log file: $flog"
fi
