#!/bin/bash

usage() {
        echo "Please check the Usage of the Script, there were no enough parameters supplied."
        echo "Usage: ArtifactoryUpload.sh localFilePath Repo GroupID ArtifactID VersionID"
        exit 1
}

if [ -z "$5" ]; then
        usage
fi

localFilePath="$1"
REPO="$2"
groupId="$3"
artifactId="$4"
versionId="$5"

ARTIFAC=http://10.40.250.70/artifactory

if [ ! -f "$localFilePath" ]; then
        echo "ERROR: local file $localFilePath does not exists!"
        exit 1
fi

which md5sum || exit $?
which sha1sum || exit $?

md5Value="`md5sum "$localFilePath"`"
md5Value="${md5Value:0:32}"

sha1Value="`sha1sum "$localFilePath"`"
sha1Value="${sha1Value:0:40}"

fileName="`basename "$localFilePath"`"
fileExt="${fileName##*.}"

echo $md5Value $sha1Value $localFilePath
echo "INFO: Uploading $localFilePath to $targetFolder/$fileName"

curl -i -X PUT -K $CURLPWD \
-H "X-Checksum-Md5: $md5Value" \
-H "X-Checksum-Sha1: $sha1Value" \
-T "$localFilePath" \
"$ARTIFAC/$REPO/$groupId/$artifactId/$versionId/$artifactId-$versionId.$fileExt"
