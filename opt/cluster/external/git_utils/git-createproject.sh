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

flog=$cwd/git-createproject.$pid.log

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
  echo "    -w [user1,user2,...]: give list of users with read-write permission to the repository"
  echo "    -r [user1,user2,...]: give list of users with read-only permission to the repository"
  echo "    -g [user group]     : set user group with which the project is shared.  Default: user's primary group"
  echo "    -o                  : open readable permission for all other users. Default: closed"
  echo "    -l                  : keep log file on success. Default: off"
  echo "==============================================================="
  echo
}

## parsing commandline arguments
group=`groups $uid | awk '{print $2}'`
open=0
rmlog=1
while getopts "hg:r:w:ol" flag
do
  case "$flag" in
    g)
      group=$OPTARG

      ## check if the user is in the specified group
      groups $uid | egrep " $group(|\s)" > /dev/null 2>&1

      if [ $? -ne 0 ]; then
          print_err "user $uid not in group $group" 0
          exit 1
      fi

      ;;
    w)
      uwlist=$OPTARG
      ;;
    r)
      urlist=$OPTARG
      ;;
    o)
      open=1
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

mode=02770
if [ $open -eq 1 ]; then
   mode=02775
fi

## required user arguments 
base=$1
proj=$2

## create directory for bare git repository
bare_repo=$base/${proj}.git

echo -ne "--> creating repository directory ... "

if [ -d $bare_repo ]; then
    fail
    print_err "directory already exist: $bare_repo" 1
    exit 1
fi

mkdir -m $mode -p $bare_repo >> $flog 2>&1

if [ $? -ne 0 ]; then
    fail
    print_err "cannot create directory: $bare_repo" 1
    exit 1
fi

success

## create access right to a specific list of users using NFSv4's ACL
if [ ! -z $uwlist ] || [ ! -z $urlist ]; then
    ## needs to add owner's id explicitly into ACL for write permission
    if [ ! -z $uwlist ]; then
        uwlist="${uwlist},$uid"
    else
        uwlist=$uid
    fi
fi

## user ACL for read-write permission
if [ ! -z $uwlist ]; then
    init_repo_acl $uwlist "w" $bare_repo
fi

## user ACL for read-only permission
if [ ! -z $urlist ]; then
    init_repo_acl $urlist "r" $bare_repo
fi

## initiate bare git repository and set proper permission for group
echo -ne "--> initializing repository ... "

cd $bare_repo

abs_bare_repo=`pwd`

git init --bare --shared=group >> $flog 2>&1

if [ $? -ne 0 ]; then
    fail
    print_err "cannot initiate repository: $bare_repo" 1
    exit 1
fi

find objects -type d -exec chmod $mode {} \;

success

## clone the git repository
echo -ne "--> cloning the repository for first commit ... "

tmpdir=/tmp/${proj}_${pid}

git clone $abs_bare_repo $tmpdir >> $flog 2>&1

if [ $? -ne 0 ]; then
    fail
    print_err "cannot clone the repository: $abs_bare_repo" 1
    rm -rf $tmpdir >> $flog 2>&1
    exit 1
fi
success

## create README file and make initial commit 
echo -ne "--> performing first commit ... "

cd $tmpdir
echo "`date`: project $proj initialized by $uid (${uname})" > README

git add README >> $flog 2>&1
git commit -m "project initialization" >> $flog 2>&1
git push -u origin master >> $flog 2>&1

if [ $? -ne 0 ]; then
    fail
    print_err "cannot push first commit to $abs_bare_repo" 1
    rm -rf $tmpdir >> $flog 2>&1
    exit 1
fi
success
rm -rf $tmpdir >> $flog 2>&1

if [ $rmlog -eq 1 ]; then
    rm -f $flog
else
    echo ""
    echo "log file: $flog"
fi

## print out instructions for client setup
echo
echo "==== repository ${proj}.git created successfully ==="
echo 
echo " use the GIT command to clone your working repository:"
echo " % git clone ssh://<login>@${host}${abs_bare_repo}"
echo
