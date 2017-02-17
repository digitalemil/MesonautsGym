#!/bin/bash
read -p "Install services? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then
	echo yes
	./setup-marathon-lb.sh
	dcos package install --yes cassandra
	dcos package install --yes kafka
	dcos package install --yes elasticsearch
	dcos marathon app add kibana.json
	read -p "Press any key when the services are started." -n1 -s 
else
	echo no
fi

if  [[ $1 == http* ]] 
then
	export PUBLICELBHOST=$(echo $1 | awk -F/ '{print $3}')
else
echo $1 | awk -F/ '{print $3}'
	export PUBLICELBHOST=$(echo $1 | awk -F/ '{print $1}')
fi
cp config.json config.tmp
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICELBHOST@g"  config.tmp
dcos marathon group add config.tmp
rm config.tmpe
