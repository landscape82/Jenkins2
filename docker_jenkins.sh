#!/bin/bash
DOCK=/usr/bin/docker
HOST=hostname
HOSTPORT=8888
CONTAINERPORT=8080
IMAGE="jenkinsci/blueocean:latest"
EXT_VOL_HOST="/localdisk/docker/volumes/jenkins_bo"
EXT_VOL_JENK="/var/jenkins_home"
BOX_NAME="jenkinsci_bo"
getBOX_ID=`docker ps -aqf "name=jenkinsci_bo"`
LOCAL="/localdisk"

echo "Pulling latest Jenkins image with BlueOcean"
docker pull $IMAGE

echo ""
echo "Creating external mount point $EXT_VOL_HOST ..."
mkdir -p $EXT_VOL_HOST
chmod 777 $EXT_VOL_HOST
echo -n "Directory created: "
ls -l $LOCAL | grep ^d

echo ""
echo -n "Starting container $IMAGE with ext storage at $EXT_VOL_HOST ... "
$DOCK run --name $BOX_NAME --detach --publish $HOSTPORT:$CONTAINERPORT --volume $EXT_VOL_HOST:$EXT_VOL_JENK $IMAGE

echo ""
echo -n "Container is up-and running Container ID: "
docker ps -aqf name=jenkinsci_bo

echo ""
echo "External storage creater, mounter, mapped with following parameters: "
docker ps -aqf "name=jenkinsci_bo" | xargs docker inspect -f '{{ .Mounts }}'
