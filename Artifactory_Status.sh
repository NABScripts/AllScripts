#!/bin/sh
#
# This scripts places the Status on the Artifact
#

export STATUS="$1"
export User="$2"
export GROUP="$3"
export ASSET="$4"
export VERSION="$5"

JENKINSROOT=/opt/EnterpriseJenkins
JENKINSHOME="$JENKINSROOT"/jenkins

ARTIFAC=http://artifactory.aus.thenational.com
CURLPWD=$JENKINSROOT/custom/secure/passwd

curl -X PUT -s -K $CURLPWD "$ARTIFAC/api/storage/nab_build/${GROUP}/${ASSET}/${VERSION}?properties=lastModifiedBy=${User}"

if [[ ${STATUS} == Testing ]]; then
        curl -X PUT -s -K $CURLPWD "$ARTIFAC/api/storage/nab_build/${GROUP}/${ASSET}/${VERSION}?properties=SCM.Approval=Approved"
elif [[ ${STATUS} == ReadyToRelease ]]; then
        curl -X POST -s -K $CURLPWD "$ARTIFAC/api/copy/nab_build/${GROUP}/${ASSET}/${VERSION}?to=nab_release/${GROUP}/${ASSET}/${VERSION}"
fi
