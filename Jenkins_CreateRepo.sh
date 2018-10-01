#!/bin/bash -x
# Script is used to create a Repository level directory under the Organisation in Jenkins Workspace
# This Script copies the Repository level directory from a existing template and places the directory under the specified Org name

# Created by Mir S Mehdi - 17/11/14

JENKINSURL=http://localhost:8080/
JENKINSBASE=/opt/EnterpriseJenkins
JENKINSHOME=/opt/EnterpriseJenkins/jenkins
SCRIPTSDIR=$JENKINSBASE/custom/scripts

#Check if the Org Level directory exists
java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL get-job $1 >/dev/null 2>/dev/null

RETORG=$?
if [ "$RETORG" == "0" ]; then
	echo "$1 already exists!!! Checking for $2..."
	java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL get-job $1/$2 >/dev/null 2>/dev/null
	RETREP=$?
	if [ "$RETREP" == "0" ]; then
		echo "$1/$2 Structure already exists in Jenkins"
		exit 1
	else
		java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL copy-job ATORGName/RepoName $1/$2
		cd $JENKINSHOME/jobs/$1/jobs/$2
	fi
else
	echo "$1 doesn't exists, Did you mean to create the Org level directory?"
	exit 1
fi

find . -depth -name '*ATORGName*' -execdir bash -c 'for f; do mv -i "$f" "${f//ATORGName/'$1'}"; done' bash {} +
find . -depth -name '*RepoName*' -execdir bash -c 'for f; do mv -i "$f" "${f//RepoName/'$2'}"; done' bash {} +

find ./ -type f | xargs sed -i 's/ATORGName/'$1'/';
find ./ -type f | xargs sed -i 's/RepoName/'$2'/';
find ./ -type f | xargs sed -i 's/Art-Repo/'$3'/';

java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL reload-job $1/$2

echo "$3,$4,$5" >> $JENKINSBASE/custom/artProperty/OrgModule.txt
