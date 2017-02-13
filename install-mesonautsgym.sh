#!/bin/bash

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
