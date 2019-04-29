#!/bin/bash
INSTALL_STEPS=jenkins2-install.log
INSTALL_ERROR=jenkins2-install-errors.log
JENKINS_LOGS=/var/log/jenkins/jenkins.log
#INIT_PASS=$(cat '/var/lib/jenkins/secrets/initialAdminPassword')

GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

# Installation preparations...
echo ""
date
echo "Starting installation from the scratch... It takes around 8m to finish..."
echo "For report tail - Progress : jenkins2-install.log; and for Errors - jenkins2-install-errors.log"
exec 1>$INSTALL_STEPS 2>>$INSTALL_ERROR
date
echo "Preperaing VM - Installing additional packages and Jenkins dependent components..."
apt autoremove -y
apt-get update
#echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y curl git gradle htop maven python ntp openjdk-8-jdk openjdk-8-jre openjdk-8-jre-headless pcregrep software-properties-common tmux unzip vim virtualenv wget

# Installing Jenkins from stable repository"
echo "Starting installation from stable repository..."
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins

# Redirect to tty
exec >/dev/tty

# Setup - Jenkins process
echo "Enabling systemd setup and starting Jenkins..."
systemctl start jenkins.service
/lib/systemd/systemd-sysv-install enable jenkins
wait 1
# Check process status
ps -aux | grep "[j]enkins" > /dev/null 2>&1
if [[ "$?" == "0" ]];
        then
                wait 2
		echo "Jenkins is up and running..."
                echo -n "Webservice output: "
                curl -s localhost:8080 | grep Auth
                echo "Logs are located in following path:" $JENKINS_LOGS
                sleep 1
		echo -n "Secret key for initial login is: "
                # Generating / concatenate secret key file
		echo -n $GREEN
		cat /var/lib/jenkins/secrets/initialAdminPassword
		echo $NORMAL
        else
                echo "Jenkins is not running... Check installation report and Jenkins logs..."
fi
