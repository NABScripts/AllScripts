#!/bin/bash

#The below log and location is for reference only 

#UPGRADE_LOG=/home/jenkins_updgradelogs.log


#EXISTING_WAR_VERSION=$1 # Give version number for existing jenkins version , this will be used in naming war backup

#NEW_FILE_NAME = $2 # Give full file path in tmp for the new file

echo $EXISTING_WAR_VERSION

version=$EXISTING_WAR_VERSION

#WAR_BACKUP=$1

cd /usr/lib/jenkins

cp -rf jenkins.war $version
if [ $? -eq 0 ] 

then

echo "WAR backup Successful"

else

echo "WAR backup is unsucessful" 

exit 

fi


echo "Starting jenkins upgrade activity " 

EnterpriseJenkinsPath=/opt/EnterpriseJenkins/

cd $EnterpriseJenkinsPath

echo "Starting jenkins backup on server " 

today=`date +%Y%m%d_%H%M%S`

Jenkins_Backup="jenkins_bkp_$today"

echo "Creating jenkins backup at $Jenkins_Backup "

cp -rf jenkins ./Backup_Upgrade/$Jenkins_Backup

if [ $? -eq 0 ] 

then

echo "Successful backup completed"

else

echo "Backup unsucessful" 

exit

fi

#ps -eaf | grep -i "jenkins"

#sudo /etc/init.d/jenkins stop


#Below line can be used if want to include manual kill in script 

#read JENKINS_PID_TO_KILL

# kill -9 $JENKINS_PID_TO_KILL


#cd /usr/lib/jenkins

#NEW_WAR_FILE_NAME

#cp -rf $NEW_WAR_FILE_NAME jenkins.war

#end
