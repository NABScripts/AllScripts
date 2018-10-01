#Collect the path and filename as RunTime Variables
filename=$1

#verify Existence of RefreshFile
if [ -f $filename ]
then
	echo "Refresh File $filename exists"
else
	echo "Couldn't find Refresh File $filename .....hence exiting"
	exit 1
fi

#################################
#If we find an error, then abort will take us here
##
abort()
{
  echo ${1}
  :
  : ERROR: ${1}
  : FAILURE: Deployment Unsuccessful
  :
  : NOTE: Carefully check all Error and Warning messages.
  exit 99
}
##########################################################################################################

echo "Validating presence of all mandatory fields..."

while read line;do
        ((Count++))
        if [[ `echo $line | grep -v "^#"` ]]
        then
			echo $line
			Asset=`echo $line | cut -d ',' -f1`
			if [[ -z ${Asset} ]]; then abort "Refresh File Syntax Error - Asset Name Missing in the line ${Count}" ; fi
			
			Env=`echo $line | cut -d ',' -f2`
			if [[ -z ${Env} ]]; then abort "Refresh File Syntax Error - Env Value Missing in the line ${Count}" ; fi
			
			Source_Path=`echo $line | cut -d ',' -f3`
			if [[ -z ${Source_Path} ]]; then abort "Refresh File Syntax Error - Source_Path Name Missing in the line ${Count}" ; fi
			
			#List of Files can be empty
			#File=`echo $line | cut -d ',' -f4`
			#if [[ -z ${File} ]]; then abort "Refresh File Syntax Error - File Name Missing in the line ${Count}" ; fi
			
			Dest_Server=`echo $line | cut -d ',' -f5`
			if [[ -z ${Dest_Server} ]]; then abort "Refresh File Syntax Error - Dest_Server Value Missing in the line ${Count}" ; fi
			
			Dest_Path=`echo $line | cut -d ',' -f6`
			if [[ -z ${Dest_Path} ]]; then abort "Refresh File Syntax Error - Dest_Path Value Missing in the line ${Count}" ; fi
			
			User=`echo $line | cut -d ',' -f7`
			if [[ -z ${User} ]]; then abort "Refresh File Syntax Error - Asset UserID Missing in the line ${Count}" ; fi
			
			System=`echo $line | cut -d ',' -f8 | tr '[:upper:]' '[:lower:]'`
			if [[ -z ${System} ]] || [[ $System != unix && $System != win32 && $System != linux ]] ; then abort "Refresh File Syntax Error - System Name Missing in the line ${Count} or value specified is wrong" ; fi
			
			Protoc=`echo $line | cut -d ',' -f9 | tr '[:upper:]' '[:lower:]'`
			if [[ -z ${Protoc} ]] || [[ $Protoc != ssh ]] ; then abort "Refresh File Syntax Error - Protocol Name Missing in the line ${Count} or value specified is wrong" ; fi
			
			#########Precmd can be empty
			#PreCmd=`echo $line | cut -d ',' -f10`
			#if [[ -z ${PreCmd} ]]; then abort "Refresh File Syntax Error - Asset Name Missing in the line ${Count}" ; fi
			
			########PostCmd can be empty
			#PostCmd=`echo $line | cut -d ',' -f11`
			#if [[ -z ${PostCmd} ]]; then abort "Refresh File Syntax Error - Asset Name Missing in the line ${Count}" ; fi
			
			########Extra should be Empty....it should exit if it has value
			#Extra=`echo $line | cut -d ',' -f12`
			#if [[ -z ${Extra} ]]; then continue; else abort "Extra Fields are Present" ; fi
        else
			continue
        fi
done < $filename
#Verify and exit if there were any issues in the Syntax
if  [ $? == 0 ]
then
	echo "Refresh File Syntax Validation successfull"
else
	echo "Refresh File Syntax Validation failed...Exiting"
	exit 1
fi 
