#!/bin/bash

NUM_DAYS="$1"
DATE_END=$(/bin/date +%D)
DATE_START=$(/bin/date --date="${NUM_DAYS} days ago -1 day" +"%D")

for ((i=0;i<$NUM_DAYS;i++))
do
	DATE_START=$(/bin/date --date="${DATE_START} +1 day" +"%F")
	#echo $DATE_START

	#t="00:00:00"
	
	for ((x=0;x<48;x++))
	do
		if [ $(($x/2*2)) -eq $x ]; then 
			echo "The current hour is $(($x/2)), $x"
			if [ $(($x/2)) -lt 10 ]; then
				t=0$(($x/2)):00:00.000000
			else
				t=$(($x/2)):00:00.000000
				echo $t
			fi
		else
			if [ $(($x/2)) -lt 10 ]; then
				t=0$(($x/2)):30:00.000000
			else
				t=$(($x/2)):30:00.000000
				echo $t
			fi
		fi

		cp -r /etc/puppetlabs/puppet/environments/production/modules/db_inject/templates/failed.erb /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}.yaml

		sed -i "s/\$time/$t/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}.yaml
		sed -i "s/\$date/$DATE_START/g" /etc/puppetlabs/puppet/environments/production/modules/db_inject/files/${DATE_START}_${t}.yaml

		#echo $DATE_START $t >> /etc/test.txt
		
		curl -k -sSF report="<${DATE_START}_${t}.yaml" https://localhost/reports/upload
	
	done
done
