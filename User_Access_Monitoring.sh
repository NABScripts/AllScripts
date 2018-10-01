#!/bin/bash
#----------------------------------
#
# To get the list of Users having acess to any group(s) in a given Organization Jenkins
#
# Author: Karthik Nataraja
#
#
#----------------------------------
JENKINSROOT=/opt/EnterpriseJenkins
JENKINSHOME="$JENKINSROOT"/jenkins
SCRIPTSDIR="$JENKINSROOT"/custom/scripts
JENKINSURL=http://localhost:8080/
WORKSPACE=$1
if [ ! -f ${SCRIPTSDIR}/Jenkins_Asset_Owner_Details.log ]
then
        echo "Input File Jenkins_Asset_Owner_Details.log not found...Exiting"
        exit 1
fi
OIFS=$IFS
IFS="
"
for line in $(cat ${SCRIPTSDIR}/Jenkins_Asset_Owner_Details.log)
do
        echo $line
        AssetName=`echo $line | cut -f1 -d":"`
        RepoName=`echo $line | cut -f2 -d":"`
        ContainerName=`echo $line | cut -f3 -d":"`
        AssetOwner=`echo $line | cut -f4 -d":"`
        OwnerEmailID=`echo $line | cut -f5 -d":"`
        if [ -z $RepoName ] || [ -z $ContainerName ]
        then
                java -jar ${SCRIPTSDIR}/jenkins-cli.jar -i ${JENKINSROOT}/custom/secure/id_rsa -s ${JENKINSURL} build -s SCM-Administration/User_Access_Reporting -p AssetName=${AssetName} -p RepoName="NULL" -p ContainerName="NULL" -p Email_ID=${OwnerEmailID} -p AssetOwner=${AssetOwner}
        else
                java -jar ${SCRIPTSDIR}/jenkins-cli.jar -i ${JENKINSROOT}/custom/secure/id_rsa -s ${JENKINSURL} build -s SCM-Administration/User_Access_Reporting -p AssetName=${AssetName} -p RepoName=${RepoName} -p ContainerName=${ContainerName} -p Email_ID=${OwnerEmailID} -p AssetOwner=${AssetOwner}
        fi
done
IFS=$OIFS
