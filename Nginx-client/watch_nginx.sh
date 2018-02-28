#!/bin/bash

# This script monitors new files in log directory, and 
# send the log to remote server.

MONITORDIR="/home/user01/var/log/nginx/"        # !!! Important !!! #

remote_login="loguser@192.168.1.113"
server_log_path=/home/log/      # !!! Important !!! #

echo " "
echo -e "Watching directory -" $MONITORDIR

# Monitor file in close_write state - file done writing and closed.
inotifywait -m -e close_write --format '%w%f' "${MONITORDIR}" | while read logfullpath
do
    # Ensure file is access##############.log format.
    filename=${logfullpath##*/}
    echo -n "Found new log:" $filename "- " ; date
    fl=26           # Toffs access log fix file length
    f7l4="${filename:0:7}${filename:${#filename}-4}"
    if [ "${f7l4}" = "access_.log" ] && [ `echo $filename | wc -c` -eq $fl ] ; then
        tempfile=$(mktemp)
        gzip -c $logfullpath > $tempfile
        mv $tempfile ${tempfile}.gz
        scp ${tempfile}.gz $remote_login:$server_log_path${filename}.gz
        echo -e ${logfullpath}.gz "sent successfully.\n" 
        rm ${tempfile}.gz
    else
        echo "Skip, not access_##############.log: " $logfullpath
        echo ""
    fi
done
