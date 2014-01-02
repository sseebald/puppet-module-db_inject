#!/bin/bash

#------< To-dos >-------
#-- input logic scrubbing
#-- clean up files


TOTAL_RUNS=$(($1*$2))
NUM_DAYS="$1"
u_NUM_RUNS="$2"
DATE_END=$(/bin/date +%D)
DATE_START=$(/bin/date --date="${NUM_DAYS} days ago -1 day" +"%F")
servers=( master centos64a centos64b centos64c debian607a ubuntu1204a solaris10a sles11a server2008r1 server2008r2b centos59a )
outcomes=( success changes pending failed )
rand_out=${#outcomes[@]}

NUM_RUNS=u_NUM_RUNS

for ((i=0;i<$NUM_DAYS;i++))
do
       	
       for ((x=0;x<$NUM_RUNS;x++))
       do
       	echo "Current run: ${x}"

       	if [ $(($x/2*2)) -eq $x ]; then 
       		if [ $((x/2)) -lt 10 ]; then
       			t=0$((x/2)):00:00.000000
       		else
       			t=$((x/2)):00:00.000000
       		fi
       	else
       		if [ $((x/2)) -lt 10 ]; then
       			t=0$((x/2)):30:00.000000
       		else
       			t=$((x/2)):30:00.000000
       		fi
       	fi

	       	for y in "${servers[@]}"
       		do
       			echo "Current server:${y}"
       		
			z="${outcomes[RANDOM % rand_out]}"

       			cp -r /etc/puppetlabs/puppet/environments/production/modules/db_inject/templates/${z}.erb /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
       	
       			sed -i "s/\$time/$t/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
       			sed -i "s/\$date/$DATE_START/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
       			sed -i "s/\$server/$y/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
       	
       			curl -k -sSF report="<${DATE_START}_${t}_${y}_${z}.yaml" https://localhost/reports/upload
       		done
	done

       DATE_START=$(/bin/date --date="${DATE_START} +1 day" +"%F")

done

#rm -rf /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/2013*

