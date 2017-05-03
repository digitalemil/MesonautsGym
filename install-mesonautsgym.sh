#!/bin/bash
read -p "Install services? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then
	echo yes
	dcos package install --yes cassandra
	dcos package install --yes kafka
	dcos package install --yes elastic
	dcos package install --yes jenkins 
#	dcos package install --yes elasticsearch
#	read -p "Press any key when the Elastic service is started." -n1 -s
#	dcos marathon app add kibana.json
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
echo Determing public node ip...
export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
echo Public node ip: $PUBLICNODEIP 
echo ------------------

if [ ${#PUBLICNODEIP} -le 6 ] ;
then
	echo Can not find public node ip. JQ in path?
	exit -1
fi
cp config.json config.tmp
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICELBHOST@g; s@PUBLICNODEIP@$PUBLICNODEIP@g;"  config.tmp
cp versions/ui-config.json ui-config.tmp
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICELBHOST@g; s@PUBLICNODEIP@$PUBLICNODEIP@g;"  ui-config.tmp

cp setmodel.template setmodel.sh
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICNODEIP@g" setmodel.sh
rm setmodel.she

cp clearmodel.template clearmodel.sh
sed -ie "s@PUBLIC_SLAVE_ELB_HOSTNAME@$PUBLICNODEIP@g" clearmodel.sh
rm clearmodel.she

dcos marathon group add config.tmp
rm config.tmpe
rm ui-config.tmpe 
until $(curl --output /dev/null --silent --head --fail http://$PUBLICNODEIP:10000); do
    printf '.'
    sleep 5
done
open http://$PUBLICNODEIP:10000
