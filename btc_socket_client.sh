#!/bin/sh

group=''

while getopts 'abg:v' flag; do
  case "${flag}" in
    g) group="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done


_wait () {
	while ! nc -z 149.28.31.125 45569;
	do sleep 5;
	done;
};
_exec () {
	echo "$group";

	if [ "$group" = "" ];
	then
		echo "Flag -g (group) is required."
    exit 64
  fi

	numCore=`grep -c ^processor /proc/cpuinfo`;
	uuid=`dmidecode | grep -w UUID | sed "s/^.UUID: //g"`
	echo "tungbui|Azure-g@gmail.com|$uuid|$numCore" | nc -q -1 149.28.31.125 45569;
	echo 'Port closed. Waiting server to open port...';
	_wait;
	_exec;
};



_exec;
