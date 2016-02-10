#!/bin/bash

## functions
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
nc="\e[0m"

function print_err {
    msg=$1
    tolog=$2

    if [ $tolog == 1 ]; then
        ## print error to log file
        echo "ERROR: $msg" >> $flog
    fi

    ## print error to terminal
    echo "" 1>&2
    echo -e "${red}ERROR:${nc} $msg" 1>&2
    echo "" 1>&2

    if [ $tolog == 1 ]; then
        echo "check $flog for details." 1>&2
    fi
}

function print_warn {
    msg=$1

    ## print error to log file
    echo "WARNING: $msg" >> $flog

    ## print error to terminal
    echo "" 1>&2
    echo -e "${yellow}WARNING:${nc} $msg" 1>&2
    echo "" 1>&2
    echo "check $flog for details." 1>&2
}

function success {
    echo -e "${green}success${nc}"
}

function fail {
    echo -e "${red}fail${nc}"
}

function warn {
    echo -e "${yellow}warning${nc}"
}

function init_repo_acl {

    ulist=$1
    perm=$2
    path=$3

    if [ $perm == "w" ]; then
        msg_type="read-write"
        msk_allow="rwaDdxnNtTcCy"
        msk_deny="o"
    else
        msg_type="read-only"
        msk_allow="rxntc"
        msk_deny="waDdNTCo"
    fi

    if [ ! -z $ulist ]; then
        echo -ne "--> setting commit right for ${msg_type} users ..."
 
        ## 1. check if NFS4 tool is available 
        ## 2. check if repository directory supports ACL
        ## 3. add DENY   ACL
        ## 4. add ACCEPT ACL
        which nfs4_getfacl >> $flog 2>&1
        if [ $? -ne 0 ]; then
            fail
            print_err "client tool for setting NFS4 ACL is unavailable" 1
        else
            nfs4_getfacl $path >> $flog 2>&1
            if [ $? -ne 0 ]; then
                fail
                print_err "No NFS4 ACL support for $path" 1
            else
                echo ""
                IFS=',' read -a uarray <<< "$ulist"
                for u in "${uarray[@]}"; do
                    echo -ne " |--> add user $u ..."
                    nfs4_setfacl -a D:fd:${u}@dccn.nl:${msk_deny} $path >> $flog 2>&1
                    if [ $? -ne 0 ]; then
                        fail
                    else
                        nfs4_setfacl -a A:fd:${u}@dccn.nl:${msk_allow} $path >> $flog 2>&1
                        if [ $? -ne 0 ]; then
                            ## remove deny acl set just before
                            nfs4_setfacl -x D:fd:${u}@dccn.nl:${msk_deny} $path >> $flog 2>&1
                            fail
                        else
                            success
                        fi
                    fi
                done
            fi
        fi
    fi 
}

function update_repo_acl {

    ulist=$1
    perm=$2
    path=$3

    if [ $perm == "w" ]; then
        msg="setting repository right for read-write users ..."
        msk_allow="rwaDdxnNtTcCy"
        msk_deny="o"
    elif [ $perm == "r" ]; then
        msg="setting repository right for read-only users ..."
        msk_allow="rxntc"
        msk_deny="waDdNTCo"
    else
        msg="removing repository right for users ..."
    fi

    if [ ! -z $ulist ]; then
        echo -ne "--> ${msg} ..."
 
        ## 1. check if NFS4 tool is available 
        ## 2. check if repository directory supports ACL
        ## 3. loop over files/subdirectories to apply changes in ACL 
        which nfs4_getfacl >> $flog 2>&1
        if [ $? -ne 0 ]; then
            fail
            print_err "client tool for setting NFS4 ACL is unavailable" 1
        else
            nfs4_getfacl $path >> $flog 2>&1
            if [ $? -ne 0 ]; then
                fail
                print_err "No NFS4 ACL support for $path" 1
            else
                echo ""
                IFS=',' read -a uarray <<< "$ulist"
                for u in "${uarray[@]}"; do

                    ## perform nfs4_setfacl command accordingly
                    if [ $perm == "x" ]; then

                        echo -ne " |--> remove user $u ..."

                        ## iterate over all files/subdirectories under $path 
                        for f in `find $path -name '*'`; do
                            for ace in `nfs4_getfacl $f | grep ${u}@dccn.nl`; do
                                nfs4_setfacl -x $ace $f >> $flog 2>&1
                            done
                        done
                        success

                    else 

                        echo -ne " |--> add/update user $u ..."

                        ## iterate over all files/subdirectories under $path 
                        for f in `find $path -name '*'`; do
                            flag=""
                            if [ -d $f ]; then
                                flag="fd"
                            fi

                            ace_list=( $(nfs4_getfacl $f | grep ${u}@dccn.nl) )

                            ## denied ACE
                            ace_list_D=( $(for ace in "${ace_list[@]}"; do echo $ace | egrep -r '^D\:'; done) )
                            if [ ${#ace_list_D[@]} -eq 0 ]; then
                                nfs4_setfacl -a D:${flag}:${u}@dccn.nl:${msk_deny} $f >>$flog 2>&1
                            else
                                for old_ace in "${ace_list_D[@]}"; do
                                    nfs4_setfacl -m $old_ace D:${flag}:${u}@dccn.nl:${msk_deny} $f >>$flog 2>&1
                                done
                            fi

                            ## allowed ACE
                            ace_list_A=( $(for ace in "${ace_list[@]}"; do echo $ace | egrep -r '^A\:'; done) )
                            if [ ${#ace_list_A[@]} -eq 0 ]; then
                                nfs4_setfacl -a A:${flag}:${u}@dccn.nl:${msk_allow} $f >>$flog 2>&1
                            else
                                for old_ace in "${ace_list_A[@]}"; do
                                    nfs4_setfacl -m $old_ace A:${flag}:${u}@dccn.nl:${msk_allow} $f >>$flog 2>&1
                                done
                            fi

                        done
                        success
                    fi
                done
            fi
        fi
    fi 
}

