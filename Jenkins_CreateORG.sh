#!/bin/bash -x

JENKINSURL=http://localhost:8080/
JENKINSBASE=/opt/EnterpriseJenkins
JENKINSHOME=/opt/EnterpriseJenkins/jenkins
SCRIPTSDIR=$JENKINSBASE/custom/scripts
SSHKEYDIR=$JENKINSBASE/custom/sshkeys
#ssh-keygen -t rsa -N "" -f $SSHKEYDIR/"$1"_"$2"

java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL copy-job ATORGName $1

cd $JENKINSHOME/jobs/$1

find . -depth -name '*ATORGName*' -execdir bash -c 'for f; do mv -i "$f" "${f//ATORGName/'$1'}"; done' bash {} +
find . -depth -name '*RepoName*' -execdir bash -c 'for f; do mv -i "$f" "${f//RepoName/'$2'}"; done' bash {} +

find ./ -type f | xargs sed -i 's/ATORGName/'$1'/';
find ./ -type f | xargs sed -i 's/RepoName/'$2'/';
find ./ -type f | xargs sed -i 's/Art-Repo/'$3'/';

java -jar $SCRIPTSDIR/jenkins-cli.jar -i $JENKINSBASE/custom/secure/id_rsa -s $JENKINSURL reload-job $1

#curl -X POST -qk -u $4 -d '{"title":"JenkinsDeployKey", "key":"'"`cat $SSHKEYDIR/$1_$2.pub`"'"}' https://github.aus.thenational.com/api/v3/repos/$1/$2/keys
#cp $JENKINSBASE/custom/refresh/ATORGName_RepoName $JENKINSBASE/custom/refresh/"$1"_"$2"
#sed -i 's/ATORGName/'$1'/g' $JENKINSBASE/custom/refresh/"$1"_"$2"
#sed -i 's/RepoName/'$2'/g' $JENKINSBASE/custom/refresh/"$1"_"$2"

echo "$3,$5,$6" >> $JENKINSBASE/custom/artProperty/OrgModule.txt
