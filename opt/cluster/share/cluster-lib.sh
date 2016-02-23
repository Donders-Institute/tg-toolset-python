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


#---------------------------------------------------------------------#
# get_script_dir: resolve absolute directory in which the current     #
#                 script is located.                                  #
#---------------------------------------------------------------------#
function get_script_dir() {
    ## resolve the base directory of this executable
    local SOURCE=$1
    while [ -h "$SOURCE" ]; do
        # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"

        # if $SOURCE was a relative symlink,
        # we need to resolve it relative to the path
        # where the symlink file was located

        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    done

    echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"
}

#---------------------------------------------------------------------#
# rem_walltime: calculate remaining hours/minutes until 8 pm          #
#---------------------------------------------------------------------#
function rem_walltime() {
    # Function to calculate the default walltime
    # This function calculates the remaining hours/minutes until
    # 20:00 (08 pm)
    # This is used as the default walltime for torque if no walltime is
    # specified in the matlab startscript (matlabXX)...
    #
    # 07nov13 - edwger

    # Determine current time and specify end time (not 8pm but 7pm for
    # calculation purpose (hours left after calculating remaining hours)
    local now=$(date +"%k:%M")
    local stop="19:00"
    
    local hrs_now=$((echo $now) | awk -F : '{ print $1 }')
    local mins_now_1=$((echo $now) | awk -F : '{ print $2 }')

    # remove leading zeros
    mins_now="$(echo $mins_now_1 | sed 's/0*//')"

    # mins_now can be 00 and becomes empty if zeros are stripped, so...
    if [ -z $mins_now ]; then
        mins_now="0"
    fi

    local hrs_remain=""
    local mins_remain=""
    if [ "$hrs_now" -ge "20" -o "$hrs_now" -lt "8" ]; then
        # Default walltime is 4 hours between 8pm and 8am (night)
        hrs_remain="04"
        mins_remain="00"
    else
        # Calculate walltime between 8am until 8pm (day)
        hrs_remain=$[19 - $hrs_now]
        mins_remain=$[60 - $mins_now]

        # mins_remain can be 60 if mins_now is 0. When mins_remain
        # equals 60 it will be changed to 00 and hrs_remain will
        # be increased by 1
        if [ "$mins_remain" -eq "60" ]; then
            mins_remain="00"
            hrs_remain=$(($hrs_remain+1))
        fi
        
        # Change walltime to 4 hours if remaining hours are less
        # then 4 hours
        if [ "$hrs_remain" -lt "4" ]; then
            hrs_remain="04"
            mins_remain="00"
        fi
    fi

    # put remaining walltime in var
    echo "$hrs_remain:$mins_remain:00"
}

#---------------------------------------------------------------------#
# torque_run_guiapp: general wrapper and interface for submitting     #
#                    interactive GUI application to the cluster.      #
#---------------------------------------------------------------------#
function torque_run_guiapp() {

    if [ $# -lt 2 ]; then
        echo "invalid number of arguments" 1>&2
        return 1
    fi

    local name_guiapp=$1
    local cmd_guiapp=$2
    local trq_queue="interactive"

    if [ $# -eq 3 ]; then
        trq_queue=$3
    fi

    echo " "
    echo "Scheduling an interactive $name_guiapp session for execution on torque:"
    echo " "

    local hrs_now=$(date +"%k:%M" | awk -F : '{ print $1 }')
    local remaining_walltime=$( rem_walltime )

    if [ $hrs_now -lt 16 ] && [ $hrs_now -ge 8 ]; then
        echo "Default your job runs until 8pm."
        echo "Specify the required time as HH:MM:SS (current default $remaining_walltime)"
    else
        echo "Specify the required time as HH:MM:SS (default $remaining_walltime)"
    fi

    echo -n "Enter time (HH:MM:SS) or press enter for default: "
    read walltime
    if [ -z "$walltime" ]; then
        walltime=$remaining_walltime
    fi

    echo " "
    echo "Specify the required memory as XXgb (default 3gb)"
    echo -n "Enter memory (XXgb) or press enter for default: "
    read mem

    if [ -z "$mem" ]; then
        mem=3gb
    fi

    while ! [[ $(echo $mem | tail -3c | tr '[:upper:]' '[:lower:]') == "gb" ]]; do
        echo " "
        echo -n "Memory value needs to be specified with required "
        echo -e "\033[1mGB/gb\033[0m!"
        echo -n "Specify the required memory as XX"
        echo -ne "\033[1m\033[5mgb\033[0m!"
        echo " (default 3gb)"
        echo -n "Enter memory (XXgb) or press enter for default: "
        read mem;
        if [ -z "$mem" ]; then
            mem=3gb
        fi
    done

    if [ ${DISPLAY:0:1} == ":" ]; then
        # the display variable is formatted as :1.0, whereas the X11 output should go to mentat001:1.0
        DISPLAY=$HOSTNAME$DISPLAY
    fi

    # replace HOSTNAME by IP_ADDRESS on DISPLAY as some GUI applications (e.g. LCModel) needs it
    local h=`echo $DISPLAY | awk -F ':' '{print $1}'`
    local no_dp=`echo $DISPLAY | awk -F ':' '{print $2}'`
    local ip=`getent ahostsv4 $h | grep $h | awk '{print $1}'`
    DISPLAY="${ip}:${no_dp}"

    # ensure that the display can be forwarded
    echo
    xhost +

    echo
    echo Requesting interactive $name_guiapp session on a suitable torque execution host using
    echo
    echo "$cmd_guiapp" | qsub -l walltime=$walltime,mem=$mem,nodes=1 -q $trq_queue
    echo

    return 0
}
