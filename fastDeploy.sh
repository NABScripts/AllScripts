#Deploy Plugin
#!/bin/sh -x
#----------------------------------
#
# This file is to validate the parameters for the Deployment Script
# Also logs the Output of the Deployment Script to a permanent location for reference
#
#----------------------------------
#------------

DATE=`date +%Y%m%d_%I%M%S`

Usage()
{
echo "Improper usage of the parameters"
echo "Make sure you have passed all the required parameters"
echo -n
echo "Usage: Deploy.sh CONFIG_FILE Asset_Name Asset_Path Version_Dir JOBNAME BUILD_User_ID UNZIP_Type Floating_Variable(Optional)"
exit 99
}

if [ -z "$6" ] ; then
echo "$1 $2 $3 $4 $5 $6 $7 $8"
Usage
fi

JENKINSROOT=/opt/EnterpriseJenkins
JENKINSHOME="$JENKINSROOT"/jenkins
SCRIPTSDIR="$JENKINSROOT"/custom/scripts
LOGSDIR="$JENKINSROOT"/custom/logs

VARPRAM="$8"

# Clearing the Logs directory under the Jobs Directory
# This is extract the Logs for the Deployment Status, Deployment verbose Log
rm -rf ../Logs/"$5"/*
mkdir -p ../Logs/"$5"

# Log file to Record the complete Log of the Deployment script
LOGFILE="$LOGSDIR"/"$1"_"$5"_"$DATE"_log.txt

STATE=`echo "$5" | awk -F"[__]" 'NF>2{print $2}'`

if [[ "$1" == "ATCSFD" || "$1" == "ADTAccountManagement" ]]; then
        (sh -x $SCRIPTSDIR/fastDeployTask-CSF.sh $1 $STATE $2 $3 $4 $6 $5 $7 "${VARPRAM}" ) | grep -v echo | tee $LOGFILE
        #(sh -x $SCRIPTSDIR/fastDeployTask-CSF.sh $1 $STATE $2 $3 $4 $6 $5 $7 "${VARPRAM}" 2>&1) | grep -v echo > $LOGFILE
else
        (sh -x $SCRIPTSDIR/fastDeployTask.sh $1 $STATE $2 $3 $4 $6 $5 $7 "${VARPRAM}" ) | grep -v echo | tee $LOGFILE
        #(sh -x $SCRIPTSDIR/fastDeployTask.sh $1 $STATE $2 $3 $4 $6 $5 $7 "${VARPRAM}" 2>&1) | grep -v echo > $LOGFILE
fi
#(sh -x $SCRIPTSDIR/fastDeployTask.sh $1 $STATE $2 $3 $4 $6 $5 $7 "${VARPRAM}" 2>&1) | grep -v echo > $LOGFILE

cd ../Logs/$5
pwd

RETLAST=0

if [ -f DeployLog-0 ]; then
        tail -n +1 DeployLog* | grep -iv 'curl' | grep -iv 'rsync' | grep -iv 'Code of Conduct' | grep -iv 'echo'
        grep RETLAST DeployLog-* && RETLAST=99
        grep -ie "connection timed out" -ie "operation not permitted" -ie "failed" DeployLog-0 > /dev/null 2>&1
        ret_status=$?
        RET=0
        if [ $ret_status -eq 0 ]
        then
                RET=99
        fi
else
        echo "No Deployments triggered"
        RET=99
fi

scp -i $JENKINSROOT/custom/secure/id_rsa $LOGFILE 10.47.45.80:/opt/EnterpriseJenkins/custom/logs/ > /dev/null 2>&1

echo "Complete verbose Log of this deployment can be found at https://jenkins.aus.thenational.com/userContent/logs/"$1"_"$5"_"$DATE"_log.txt"

echo "Return Last - $RETLAST"

if [[ ${RETLAST} -eq 0 && ${RET} -eq 0 ]]; then
        echo "Overall Status - OK"
        exit 0
else
        echo "Overall Status - Failed"
        exit 99
fi
