#!/bin/bash

function wait {
	while ! nc -z h.tung.pro 8000; do   
	  sleep 1
	done
}

function exec {
	nc h.tung.pro 8000
	echo "Port closed. Waiting server to open port..."
	wait
	exec
}
exec
