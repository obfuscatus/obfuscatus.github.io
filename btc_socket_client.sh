#!/bin/bash

function wait {
	while ! nc -z h.tung.pro 8000; do   
	  sleep 1 # wait for 1/10 of the second before check again
	done
}

function exec {
	echo "a" | nc -q -1 h.tung.pro 8000
	echo "Port closed. Waiting server to open port..."
	wait
	exec
}
exec
