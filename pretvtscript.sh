Jenkins_URL=https://jenkins-dev.austest.thenational.com/
Username=$1
API_token=$2
Choice=$3

Pre_TVT()
{
echo "########Executing pre TVT Steps######"
whoami
#sudo /etc/init.d/jenkins status
#service jenkins status
echo "Checking Jenkins Status\n"
processes=`ps -eaf | grep -i "jenkins.war" | wc -l`
echo $processes
if [[ $processes -ne 2 ]] 
then 
echo "$processes"
echo " Jenkins is down"
exit 1;
else
echo "Jenkins is running"
fi

echo "####### checking mount points is started ##########"
devices=`df -h | grep -E "/opt/EnterpriseJenkins" | wc -l`
if [[ "$devices" -lt 1 ]]
then
     echo " Mount point is not available\n"
     echo " "
     exit 2;
else
     echo " Creating a file(test.sh and printing hostname in the file) to check the read,write and execute permission on /opt/EnterpriseJenkins"
     echo " "
     echo hostname >/opt/EnterpriseJenkins/test.sh
     sh /opt/EnterpriseJenkins/test.sh
     echo " "
     if [ $? -eq 0 ]
     then 
         echo "File is created and Have permission to /opt/EnterpriseJenkins "
     else  
         echo "File is not created and Dont have permission to /opt/EnterpriseJenkins"
     fi
fi
echo " "
echo " "
echo "########Fetching the nodes status on the $Jenkins_URL #########\n"
curl -k --user $Username:$API_token "$Jenkins_URL/computer/api/json?depth=0&pretty=true&tree=computer\[displayName,offline\]" | sed 's/false/false->Slave is Online/g; s/true/true->Slave is offline/g'
if [ $? -eq 0 ]
then 
  echo " "
  echo "Curl command is working"
else
  echo " "
  echo "Curl command is failing "
  exit 3;
fi
echo " "
echo " "
echo " #####Triggering Build jobs running on Linux and Windows Slave to check the Connection between GIT,JENKINS AND ARTIFACTORY####"
echo "Downstream Jobs are executing"
}

Post_TVT()
{
echo "Executing post TVT Steps"
whoami
#sudo /etc/init.d/jenkins status
#service jenkins status
echo "#######Checking Jenkins Status########"
numprocesses=`ps -eaf | grep -i "jenkins.war" | wc -l`
echo $numprocesses
if [[ $numprocesses -ne 2 ]] 
then 
echo " Jenkins is down"
exit 1;
else
echo "Jenkins is running"
fi
echo "####### checking mount points is started ##########"
devices=`df -h | grep -E "/opt/EnterpriseJenkins" | wc -l`
if [[ "$devices" -ne 1 ]]
then
     echo " Mount point is not available"
     exit 2;
else
     echo " Creating a file(test.sh and printing hostname in the file) to check the read,write and execute permission on /opt/EnterpriseJenkins"
     echo " "
     echo hostname >/opt/EnterpriseJenkins/test.sh
     sh /opt/EnterpriseJenkins/test.sh
     if [ $? -eq 0 ]
     then 
         echo "File is created and Have permission to /opt/EnterpriseJenkins "
     else  
         echo "File is not created and Dont have permission to /opt/EnterpriseJenkins"
     fi
fi
echo " "
echo " "
echo "######Fetching the nodes status on the $Jenkins_URL #######"
curl -k --user $Username:$API_token "$Jenkins_URL/computer/api/json?depth=0&pretty=true&tree=computer\[displayName,offline\]"  | sed 's/false/false->Slave is Online/g; s/true/true->Slave is offline/g'
if [ $? -eq 0 ]
then 
  echo "Curl command is working"
else
  echo "Curl command is failing "
  exit 3;
fi
echo " "
echo " "
echo " #####Triggering Build jobs running on Linux and Windows Slave to check the Connection between GIT,JENKINS AND ARTIFACTORY####"
echo "Downstream Jobs are executing"
}

if [ $Choice = pre ]
then
    Pre_TVT
elif [ $Choice = post ]
then 
    Post_TVT 
else 
    echo "Give input to execute"
fi
