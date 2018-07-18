#!/bin/bash
# The script rotates the communication channels, if the main channel is unavailable, 
# a switch to the backup channel takes place. An attempt is always made to return to 
# the main communication channel. For the module to work, you also need file creation rights.

ip='192.168.0.1'; #IP address of the main communication channel
filename='file.txt';
function connect1
{
	echo 'Connect 1 --------------';
	# here we write a command that raises the main channel
	exit
}

function connect2
{
	echo 'Connect 2 --------------';
	# here we write a command that raises a backup channel
	exit
}


function sendfile
{
	echo $1>>$filename;
}

function pingrun
{
STATUS=`ping $1 -c 1 -w 2 | grep " 1 received"`
if [[ -z "$STATUS" ]]; then
  echo 0
else
  echo 1
fi
}

st=0;
stznak="";
firstznak="";
tail -n -6 "$filename" > "$filename.tmp" && mv "$filename.tmp" "$filename";
sendfile $(pingrun "$ip");

while read line
do 	
	if [ "$stznak" = "" ]; then 
		stznak="$line";
		firstznak="$line";
	else 
		if [ "$stznak" = "$line" ]; then let "st=$st+1"; 
		else let "st=0"; let "stznak=$line";
		fi 
	fi
	if [ "$firstznak" -ne "$stznak" ]; then
		if [ "$st" -gt "4" ]; then
			if [ "$stznak" -eq "1" ]; then connect1; fi;
			if [ "$stznak" -eq "0" ]; then connect2; fi;
		fi;
	fi;
done < $filename;