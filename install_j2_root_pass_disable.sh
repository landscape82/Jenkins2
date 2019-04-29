#!/bin/bash
CFG_FILE=/var/lib/jenkins
JENK_XML=config.xml

cp $CFG_FILE/$JENK_XML{,.backup}

for cfg in $CFG_FILE/$JENK_XML;
do 
	echo "Proceed with backup of Jenkins config.xml file..."
	cp $cfg{,.backup}
	echo "Backup done:"
	ls -la $cfg* | awk -F' ' '{print $3":"$4 " " $9}' | column -tx
done
echo "Following lines will be removed - to disable password authentication"
cat /var/lib/jenkins/config.xml |grep -iE "useSecurity|authorizationStrategy"
echo "Removing entries..."
sed -i 's/<useSecurity>true/<useSecurity>false/' /var/lib/jenkins/config.xml
#ex +g/useSecurity/d +g/authorizationStrategy/d -scwq /var/lib/jenkins/config.xml
echo "Check if its really removed..."
cat /var/lib/jenkins/config.xml |grep -iE "useSecurity|authorizationStrategy"
echo "Setting up proxy..."
cat $CFG_FILE/proxy.xml | grep -iE "name|port"
cp proxy.intel $CFG_FILE/proxy.xml
cat $CFG_FILE/proxy.xml | grep -iE "name|port"
systemctl stop jenkins
sleep 3
systemctl start jenkins

