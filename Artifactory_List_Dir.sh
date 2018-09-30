#!/bin/bash
#----------------------------------
#
# To get the directory list of Org's and Repo's from Artifactory
#
# Author: Mir S Mehdi
#
# Requires the credentials to connect to Artifactory to Read or Write objects
#
# Note: During implementation, requires to define the Target Location of the property files and also the Artifactory URL
#
#----------------------------------

JENKINSROOT=/opt/EnterpriseJenkins
JENKINSHOME="$JENKINSROOT"/jenkins
SCRIPTSDIR="$JENKINSROOT"/custom/scripts
FILELOC="$JENKINSROOT"/custom/artProperty

[ ! -d $FILELOC ] && mkdir -p $FILELOC
ARTURL=https://artifactory.aus.thenational.com
CURLPWD="$JENKINSROOT"/custom/secure/artifactoryPasswd
CONTYPE="Content-Type: application/json"
jq=$SCRIPTSDIR/jq

cd $FILELOC

OLDIFS=$IFS
IFS=","

while read f1 f2 f3
do
	for state in build verify release
	do
		[ ! -f $f1.list ] && touch $f1.list
		sed -i "s/.*$f2-$f3-$state.*//g" "$f1".list
		echo -n "$f2-$f3-$state=" >> "$f1".list
		VERLIST=`curl -qk -X GET -K $CURLPWD -H "$CONTYPE" $ARTURL/api/search/versions?g=$f2'&'a=$f3'&'repos=$f1-$state | $jq .results | $jq '.[].version'`
		echo $VERLIST | sed 's/\"//g' | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}' >> "$f1".list
		sed -i '/^\s*$/d' "$f1".list
	done
done < OrgModule.txt

IFS=$OLDIFS

chmod 777 -R "$FILELOC"/*
