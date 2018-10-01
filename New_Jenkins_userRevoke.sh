#!/bin/bash
#----------------------------------
# This script is to perform a Segregation of Duties check for production deployment jobs.
#
# Author: Karthik Nataraja
#----------------------------------

NONE='\033[00m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'

function revokePermission()
{
        local FOLDER=$1
        local GROUP=$2
        local USER_ID=$3

        USERS=`java -jar $JENKINSJAR -i $JENKINSCUSTBASE/secure/id_rsa -s $JENKINSURL group-membership $FOLDER $GROUP`
        echo $USERS | grep -w "$USER_ID" > /dev/null
        RET=$?
        if [ $RET == "0" ]
        then
                echo -e "${BOLD}${GREEN}\n$USER_ID is Found in $GROUP under $FOLDER...${NONE}"
        else
                echo -e "${BOLD}${RED}\n****Error finding $USER_ID user in $GROUP under $FOLDER...****${NONE}"
                #exit 1
        fi

        UPDATED_USER_LIST=`echo $USERS | sed "s/$USER_ID//g"`
        #echo "UPDATED_USER_LIST = $UPDATED_USER_LIST"
        #echo "java -jar $JENKINSJAR -i $JENKINSCUSTBASE/secure/id_rsa -s $JENKINSURL group-membership $FOLDER $GROUP $UPDATED_USER_LIST"
        #echo "java -jar $JENKINSJAR -i $JENKINSCUSTBASE/secure/id_rsa -s $JENKINSURL group-membership $FOLDER $GROUP | grep $USER_ID"
        java -jar $JENKINSJAR -i $JENKINSCUSTBASE/secure/id_rsa -s $JENKINSURL group-membership $FOLDER $GROUP "$UPDATED_USER_LIST"
        java -jar $JENKINSJAR -i $JENKINSCUSTBASE/secure/id_rsa -s $JENKINSURL group-membership $FOLDER $GROUP | grep -w "$USER_ID"
        RET=$?
        if [ $RET == "0" ]
        then
                echo -e "${BOLD}${RED}\n**** Error removing $USER_ID user to $GROUP under $FOLDER...****${NONE}"
        else
                echo -e "${BOLD}${GREEN}\nRemoval of $USER_ID from $GROUP under $FOLDER Completed...${NONE}"
        fi
}

function Revoke_access_Folder_level() {

        local Folder=$1
        local Group=$2
        local User=$3

        revokePermission $Folder $Group $User
        #echo $?
}

function Revoke_access_Repo_level() {

        local Org=$1
        local Repo=$2
        local Role=$3
        local User=$4

        if [ $Role == "OrgAdmin" ] || [ $Role == "View" ]
        then
                Group=$Org$Role
        else
                Group=$Repo$Role
        fi

        Folders=`ls /opt/EnterpriseJenkins/jenkins/jobs/${Org}/jobs/${Repo}/jobs/`
        if [ -z "$Folders" ]
        then
                echo -e "${RED}${BOLD}\nNo Folders found...hence Exiting"
                exit 5
        else
                echo -e "${BLUE}${BOLD}\nTotal Folders found under ${Org}/${Repo} -->  \n$Folders"
        fi

        for folder in $( echo $Folders | sed -n 1'p' | tr " " '\n' )
        do
                echo -e "${GREEN}\nRevoking $Group Access under ${Org}/${Repo}/$folder...${NONE}"
                Revoke_access_Folder_level ${Org}/${Repo}/$folder $Group $User
        done

}

function Revoke_access_Org_level() {

        local Org=$1
        local User=$2
        local Role=$3

        Repos=`ls /opt/EnterpriseJenkins/jenkins/jobs/${Org}/jobs/`
        if [ -z "$Repos" ]
        then
                echo -e "${RED}${BOLD}\nNo Repos found...hence Exiting"
                exit 5
        else
                echo -e "${BLUE}${BOLD}\nTotal Repos found under $Org -->  \n$Repos"
        fi

        for repository in $( echo $Repos | sed -n 1'p' | tr " " '\n' )
        do
                echo -e "${GREEN}\nRevoking $Group Access under ${Org}...${NONE}"
                Revoke_access_Repo_level $Org $repository $Role $User
        done

}


#################################################################################f
#
#       Main Script starts here
#
##################################################################################
JENKINSCUSTBASE=/opt/EnterpriseJenkins/custom
JENKINSJAR=${JENKINSCUSTBASE}/scripts/jenkins-cli.jar
JENKINSURL=http://localhost:8080

REVOKELEVEL=$1
ORGNAME=$2
REPONAME=$3
FOLDERNAME=$4
TARGETUSER=$5
REVOKE_TYPE=$6

if [ $REVOKE_TYPE == "All" ]
then
        REVOKE_TYPE="OrgAdmin,Configure,Execute,View"
fi

for ROLE in `echo $REVOKE_TYPE | tr ',' '\n'`
do
        if [ $ROLE == "Execute" ]; then
                FolderGroupName="$3Execute"
        elif [[ $ROLE == "Configure" ]]; then
                FolderGroupName="$3Configure"
        elif [[ $ROLE == "OrgAdmin" ]]; then
                FolderGroupName="$2OrgAdmin"
        elif [[ $ROLE == "View" ]]; then
                FolderGroupName="$2View"
        else
                echo -e "${BOLD}${RED}\nInvalid Role Name Selected... Exiting...${NONE}"
                exit 1
        fi

        ORGGROUPNAME="$1"Viewer

        case $REVOKELEVEL in
                ORG_LEVEL)
                        if [ $ORGNAME == "" ] || [ $ORGNAME == "NA" ]
                        then
                                echo -e "${RED}${BOLD}\nORGNAME is EMPTY OR NA, Please retry with correct set of parameters...${NONE}"
                                exit 1
                        fi

                        if [ $ROLE == "OrgAdmin" ] || [ $ROLE == "View" ]
                        then
                                Revoke_access_Folder_level $ORGNAME $FolderGroupName $TARGETUSER
                                if [ $? -eq 0 ]
                                then
                                        echo -e "${GREEN}${BOLD}\nRevoke ORG_LEVEL Completed Successfully${NONE}"
                                        #exit 0
                                else
                                        echo -e "${RED}${BOLD}\nRevoke ORG_LEVEL Failed Successfully..Retry again or contact Enterprise Jenkins Team...${NONE}"
                                        #exit 1
                                fi
                        else
                                Revoke_access_Org_level $ORGNAME $TARGETUSER $ROLE
                                if [ $? -eq 0 ]
                                then
                                        echo -e "${GREEN}${BOLD}\nRevoke ORG_LEVEL Completed Successfully${NONE}"
                                        #exit 0
                                else
                                        echo -e "${RED}${BOLD}\nRevoke ORG_LEVEL Failed Successfully..Retry again or contact Enterprise Jenkins Team...${NONE}"
                                        #exit 1
                                fi
                        fi
                ;;
                REPO_LEVEL)
                        if [ $ORGNAME == "" ] || [ $ORGNAME == "NA" ] || [ $REPONAME == "" ] || [ $REPONAME == "NA" ]
                        then
                                echo -e "${RED}${BOLD}\nORGNAME or REPONAME is EMPTY OR NA, Please retry with correct set of parameters...${NONE}"
                                exit 1
                        fi

                        Revoke_access_Repo_level $ORGNAME $REPONAME $ROLE $TARGETUSER
                        if [ $? -eq 0 ]
                        then
                                echo -e "${GREEN}${BOLD}\nRevoke REPO_LEVEL Completed Successfully${NONE}"
                                #exit 0
                        else
                                echo -e "${RED}${BOLD}\nRevoke REPO_LEVEL Failed Successfully..Retry again or contact Enterprise Jenkins Team...${NONE}"
                                #exit 1
                        fi
                ;;
                FOLDER_LEVEL)
                        if [ $ORGNAME == "" ] || [ $ORGNAME == "NA" ] || [ $REPONAME == "" ] || [ $REPONAME == "NA" ] || [ $FOLDERNAME == "" ] || [ $FOLDERNAME == "NA" ]
                        then
                                echo -e "${RED}${BOLD}\nOne or more Fields are EMPTY OR NA, Please retry with correct set of parameters...${NONE}"
                                exit 1
                        fi

                        Revoke_access_Folder_level $ORGNAME/$REPONAME/$FOLDERNAME $FolderGroupName $TARGETUSER
                        if [ $? -eq 0 ]
                        then
                                echo -e "${GREEN}${BOLD}\nRevoke FOLDER_LEVEL Completed Successfully${NONE}"
                                #exit 0
                        else
                                echo -e "${RED}${BOLD}\nRevoke FOLDER_LEVEL Failed Successfully..Retry again or contact Enterprise Jenkins Team...${NONE}"
                                #exit 1
                        fi
                ;;
                *)
                        echo -e "${RED}\nINVALID OPTION PASSED as $REVOKELEVEL"
                        exit 10
                ;;
        esac
done
