#!/bin/bash

#------< To-dos >-------
#-- input logic scrubbing
#-- clean up files

NUM_DAYS="$1"
NUM_RUNS="$2"
DATE_END=$(/bin/date +%D)
DATE_START=$(/bin/date --date="${NUM_DAYS} days ago -1 day" +"%F")
servers=( master centos64a centos64b centos64c debian607a ubuntu1204a solaris10a sles11a server2008r1 server2008r2b centos59a )
outcomes=( success changes pending failed )
	
for z in "${outcomes[@]}"
do
	for ((i=0;i<$NUM_DAYS;i++))
	do
		case $z in
			"success") NUM_RUNS=$(($NUM_RUNS/2))
			;;
			"changes") NUM_RUNS=$(($NUM_RUNS/4))
			;;
			"pending") NUM_RUNS=$(($NUM_RUNS/6))
			;;
			"failed") NUM_RUNS=$(($NUM_RUNS/6))
			;;
		esac

		for ((x=0;x<$NUM_RUNS;x++))
		do
			
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

				cp -r /etc/puppetlabs/puppet/environments/production/modules/db_inject/templates/${z}.erb /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
			
				sed -i "s/\$time/$t/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
				sed -i "s/\$date/$DATE_START/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
				sed -i "s/\$server/$y/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}_${y}_${z}.yaml
			
				curl -k -sSF report="<${DATE_START}_${t}_${y}_${z}.yaml" https://localhost/reports/upload
			done
		done
	done
done

#rm -rf /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/2013*

