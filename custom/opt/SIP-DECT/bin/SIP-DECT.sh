OMM_BIN="/opt/SIP-DECT/bin/SIP-DECT"
OMM_VERSION=00000000:00000000
OMM_ENDLESS="/var/lock/subsys/SIP-DECT-SH.endless"
OMM_PID_FILE="/var/run/SIP-DECT.pid"
OMM_CORE_PATTERN="core"
ICS_BIN="/opt/SIP-DECT/bin/ics"
ICS_PID_FILE="/var/run/SIP-ICS.pid"
ICS_LOG_FILE="/opt/SIP-DECT/tmp/ics.log"

OMM_DIR="/opt/SIP-DECT"
OMM_CORE_DIR="/opt/SIP-DECT/tmp"
OMM_CORE_PATTERN="core"

exec 2>&1 > /var/log/SIP-DECT.log

trap "logger $0 get signal and ignored!" 1 2 3 10 15

# found core files from own application 
# and compress with gzip
compress_own_core_files()
{
omm_name=`echo $OMM_BIN|sed -e's/^.*\///'`
for core_files in $OMM_CORE_PATTERN*
	do
		count=`file $core_files|grep -c $omm_name`
		if [[ $count -ge 1 ]]
		    then
		      echo "Found core file: $core_files from $omm_name, compressing..."
		      gzip $core_files
		      mv $core_files.gz $OMM_CORE_DIR
		    fi
	done	
}

#remove more than 10 Corefiles
#latest first
remove_own_core_files()
{
MAX_CORE_FILES=10
core_file_number=`ls $OMM_CORE_DIR/*.gz 2>/dev/null|wc -w`
core_files_delete=`expr $core_file_number - $MAX_CORE_FILES`
while [ $core_files_delete -ge 1 ]
  do
     file_delete=`ls -1rt $OMM_CORE_DIR/*.gz 2>/dev/null |head -1`
     echo "remove core file $file_delete"
     rm $file_delete
      core_files_delete=`expr $core_files_delete - 1`
    done
}
#Get all parameters
read_omm_parameter()
{
if [ -f /etc/sysconfig/SIP-DECT ];then
        . /etc/sysconfig/SIP-DECT
fi

#Get all parameters
#OMM_START_PARAMETER=" -http 8080 -https 8443"
OMM_START_PARAMETER=" "
ICS_START_PARAMETER=" "
 	if [ -n "$OMM_IF" ]; then
 	   OMM_START_PARAMETER="${OMM_START_PARAMETER} -i ${OMM_IF}"
 	   ICS_START_PARAMETER="${ICS_START_PARAMETER} -i ${OMM_IF}"
 	fi   
 	
 	if [ -n "$OMM_CONFIG_FILE" ]; then
 	   OMM_START_PARAMETER="${OMM_START_PARAMETER} -f ${OMM_CONFIG_FILE}"
 	fi

  	if [ -n "$OMM_RESILIENCY" ]; then
 	   OMM_START_PARAMETER="${OMM_START_PARAMETER} -m ${OMM_RESILIENCY}"
 	fi   
    
}	


if [ ! -x ${OMM_BIN} ]; then
	echo -n "OMM, ${OMM_BIN} not installed!"
	exit 5
fi


ulimit -n 32768 -c unlimited
cd "$OMM_DIR"
read_omm_parameter 	
omm_name=`echo $OMM_BIN|sed -e's/^.*\///'`

${OMM_BIN}  ${OMM_START_PARAMETER} -d
pidof -s ${OMM_BIN} -o%PPID >${OMM_PID_FILE}

sleep 3
if [ -x ${ICS_BIN} ]; then
	${ICS_BIN}  ${ICS_START_PARAMETER} -d 
	pidof -s ${ICS_BIN} -o%PPID >${ICS_PID_FILE}
fi


while [  -e "$OMM_ENDLESS$$" ]
 do    
    kill -s CONT `cat ${OMM_PID_FILE}`  2>/dev/null
    if [ $? != 0 ]; then 
     compress_own_core_files
    remove_own_core_files
    read_omm_parameter
    #for safety reason, we clean process system from omm programs
    grep -qi $omm_name  /proc/[0-9]*/stat
    if [  $? == 0 ]; then
      	killall  -q  $omm_name
           sleep 3
          killall  -q -9 $omm_name
           sleep 3
    fi
    # end safety cleanup
     echo "Restart ${OMM_BIN}"
    ${OMM_BIN}  ${OMM_START_PARAMETER} -d
    pidof  -s ${OMM_BIN} -o%PPID >${OMM_PID_FILE}
    sleep 3
	fi
	
	# ICS
	if [ -x ${ICS_BIN} ]; then
		kill -s CONT `cat ${ICS_PID_FILE}`  2>/dev/null
	    if [ $? != 0 ]; then
	         echo "Restart ${ICS_BIN}" 
	    	${ICS_BIN}  ${ICS_START_PARAMETER} -d 
			pidof -s ${ICS_BIN} -o%PPID >${ICS_PID_FILE}
		fi
	fi	
	sleep 3
	        
done
echo " $0 with PID: $$ is stopped!" 
