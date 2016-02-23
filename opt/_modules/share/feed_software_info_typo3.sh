#!/bin/bash

sw_base="/mnt/software"

source $sw_base/_modules/setup.sh

sw_list=$( for m in `module avail 2>&1 | grep -v '_modules'`; do echo $m; done | sort | awk 'func d(n){for(x=n;x<=NF-1;x++){y=x+1;$x=$y}NF--};BEGIN{FS=OFS="/"}{d(NF);print}'| uniq )

echo "<strong>Software</strong>|<strong>Description</strong>|<strong>Responsible</strong>"

for sw in $sw_list; do

    uid=$( ls -ld ${sw_base}/${sw} | awk '{print $3}' )

    if [ $uid == "root" ]; then
        uname="<a href=\"mailto:helpdesk@fcdonders.ru.nl\">TG</a>"
    else
        uname=$( finger $uid | grep 'Name' | awk -F 'Name:' '{print $NF}' | sed 's/^\s*//g' )
    fi

    #module_data=$( module whatis $sw 2>&1 | grep ':' | awk -F ' : ' '{print $NF}' | sed 's/^|//g' | sed 's/|$//g' )
    module_data=$( module whatis $sw 2>&1 | grep ':' | awk -F ' : ' '{print $NF}' | sed 's/\s*|\s*/|/g' | awk -F '|' '{ if ($3 ~ /http/) {print "<a href=\""$3"\">"$2"</a>|"$5; } else if ($4 ~ /http/ ) { print "<a href=\""$4"\">"$2"</a>|"$5; } else { print $2"|"$5}; }')
    
    echo "$module_data|$uname"

done | sort | uniq
