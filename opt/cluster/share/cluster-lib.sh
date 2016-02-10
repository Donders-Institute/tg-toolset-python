#!/bin/bash
#
# Helper functions for cluster-* scripts

MENTAT_MACHINE_FILE=$CLUSTER_UTIL_ROOT/etc/machines.mentat
TORQUE_MACHINE_FILE=$CLUSTER_UTIL_ROOT/etc/machines.torque
LOCAL_MACHINE_FILE=~/machines
MACHINE_FILES="$LOCAL_MACHINE_FILE $MENTAT_MACHINE_FILE $TORQUE_MACHINE_FILE"

function isSuperUser() {
    GRID=$(id -g "$(whoami)")

    if [ $GRID -eq 0 ] || [ $GRID -eq 601 ]; then
        echo 1
    else
        echo 0
    fi
}

function getRawReport()
{
	port=$1
	
	for machine in $MACHINES
	do
		# get load info from the machine
		report=`socket_client $machine $port 2> /dev/null`
		if [ "$report" == "" ]
		then
			echo $machine is not available >&2
		else
			# insert machine name and filter comma's out of the report
			echo $machine $report | sed 's/,//g'
		fi
	done
}
function randomline()
{
	inputfile=$1
	lines=`wc -l $inputfile | awk '{ print $1 }'`
	rndnumber=$RANDOM
	let "rndnumber %= $lines"
	let "rndnumber += 1"
	sed "${rndnumber}q;d" $1
}


function extramatlabs()
{
	extra_matlabs=/opt/cluster/.extra_matlabs
	highestmentatnumber=`cat /opt/cluster/machines  | tail -1 | sed 's/mentat//'`
	fromno=`expr $highestmentatnumber + 1`
	tono=500


	# add some dummy data ;-)
	for number in `seq $fromno $tono`
	do
		randomline $extra_matlabs | sed "s/QQQ/${number}/"
		usleep $(bc <<< "$RANDOM * 2")
	done
}


