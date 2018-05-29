#!/bin/sh
#btc_socket_client.sh -g azure-email@mailholder.com - i gekkoxid

_wait () {
	# -z: The -z flag can be used to tell nc to report open ports, rather than initiate a connection. 
	while ! nc -z 149.28.31.125 45569;
	do sleep 5;
	done;
};
_exec () {
	if [ "$group" = "" ]; then
		echo "Flag -g (group) is required."
    exit 64
  fi

  if [ "$gid" = "" ]; then
		echo "Flag -i (gekkoxId) is required."
    exit 64
  fi

	numCore=`grep -c ^processor /proc/cpuinfo`;
	uuid=`dmidecode | grep -w UUID | sed "s/^.UUID: //g"`
	
	while nc -z 149.28.31.125 45569 ; do echo "$gid|$group|$uuid|$numCore" ; sleep 30; done | nc 149.28.31.125 45569;
	echo 'Port closed. Waiting server to open port...';
	_wait;
	_exec;
};


group=''
gid=''

while getopts 'g:i:' flag; do
  case "${flag}" in
  	i) gid="${OPTARG}" ;;
    g) group="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

_exec;
