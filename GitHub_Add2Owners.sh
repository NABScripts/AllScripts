#!/bin/sh 

# This script will add the supplied user to all Organisations to which the executing user has access to
# To run this script the user token variable has to be Supplied, followed by the UserID
# The authentication of this command can be changed from UserToken to UserID/Password by replacing "-u "$UserToken":x-oauth-basic" to "-u user:password"

sh ./GitHub_ListOrg.sh $1

UserToken=$1
username=$2

while read line
do
	ORGNAME=$line
	TeamID=`curl -qk -X GET -u "$UserToken":x-oauth-basic -H "Content-Type: application/json" https://github.global.thenational.com/api/v3/orgs/$ORGNAME/teams | /z/WorkArea/Scripts/GitHub/jq.exe '.[0].id'`
	curl -qk -X PUT -u "$UserToken":x-oauth-basic -H "Content-Length: 0" https://github.global.thenational.com/api/v3/teams/$TeamID/members/$username 
done < OrgList.txt
