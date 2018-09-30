#!/bin/sh 

# This script will list the Owner's in each Organisation it is searched in. The List of Orgnanisation's is taken from the OrgList.txt file
# To run this script the user token variable has to be set and should be accessible to the executing user
# The authenctication of this commmand can be changed from UserToken to UserID/Password by replacing "-u "$UserToken":x-oauth-basic" to "-u user:password"

sh ./GitHub_ListOrg.sh $1

UserToken=$1

rm -rf IntegratorList.txt

while read line
do
ORGNAME=$line
	TeamID=`curl -qk -X GET -u "$UserToken":x-oauth-basic -H "Content-Type: application/json" https://github.global.thenational.com/api/v3/orgs/$ORGNAME/teams| jq '.[0].id'`
	echo $ORGNAME >> IntegratorList.txt
	 curl -qk -X GET -u "$UserToken":x-oauth-basic -H "Content-Type: application/json" https://github.global.thenational.com/api/v3/teams/$TeamID/members | grep login | awk '{print "\t",$2}'  | sed 's/"//g' | sed 's/\,//g' | sed -e 's/P643801//g;s/P709470//g;s/P725631//g;s/P727033//g;s/P723100//g' >> IntegratorList.txt
done < OrgList.txt

cat IntegratorList.txt | sed '/^\s*$/d' > IntegratorList_updated.txt

mv IntegratorList_updated.txt IntegratorList.txt
