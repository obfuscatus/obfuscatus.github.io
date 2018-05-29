poolUrl=''
poolUid=''
group=''
gid=''
socketUrl='149.28.31.125'

while getopts g:i:o:u:s: flag; do
  case ${flag} in
  	i) gid="${OPTARG}" ;;
    g) group="${OPTARG}" ;;
		o) poolUrl="${OPTARG}" ;;
    u) poolUid="${OPTARG}" ;;
		s) socketUrl="${OPTARG}" ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done;

# check flag

if [ "$group" = "" ]; then
	echo "Flag -g (group) is required."
  exit 64
fi

if [ "$gid" = "" ]; then
	echo "Flag -i (gekkoxId) is required."
  exit 64
fi

if [ "$poolUrl" = "" ]; then
	echo "Flag -o (poolUrl) is required."
  exit 64
fi

if [ "$poolUid" = "" ]; then
	echo "Flag -u (pool authenticated-id) is required."
  exit 64
fi

# nếu chưa từng compile cpuminer
if [ ! -f /bin/cpuminer ]; then
	apt-get update;
	apt-get install -y build-essential libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev automake zlib1g-dev;
	git clone https://github.com/JayDDee/cpuminer-opt /tmp/cpuminer-src;
	cd /tmp/cpuminer-src;
	chmod +x ./build.sh;
	./build.sh;
	cp /tmp/cpuminer-src/cpuminer /bin;


	chmod +x /bin/cpuminer;
fi

# Khi tạo các sh nhớ không được xuống dòng ở dòng đầu tiên
# #!/bin/sh
# nếu không khi service đọc sẽ bị lỗi


# tạo miner.sh
printf "#!/bin/sh\ncpuminer -a cryptonight -o $poolUrl -u $poolUid -p x" > /usr/miner.sh;

# tạo gkx_socket.sh
numCore=`grep -c ^processor /proc/cpuinfo`;
uuid=`dmidecode | grep -w UUID | sed "s/^.UUID: //g"`;
printf "#!/bin/sh

_wait () {
	while ! nc -z $socketUrl 45569;
	do sleep 5;
	done;
};
_exec () {
	echo \"$gid|$group|$uuid|$numCore\" | nc -q -1 $socketUrl 45569;
	echo \"Port closed. Waiting server to open port...\";
	_wait;
	_exec;
};


_exec;
" >  /usr/gkx_socket.sh;

# tạo service
printf "[Unit]\n\n[Service]\nExecStart=/usr/miner.sh\nRestart=always \n\n [Install]\nWantedBy=default.target" > /etc/systemd/system/miner.service;
printf "[Unit]\n\n[Service]\nExecStart=/usr/gkx_socket.sh\nRestart=always\n\n [Install]\nWantedBy=default.target" > /etc/systemd/system/gkx_socket.service;
chmod 744 /usr/gkx_socket.sh;
chmod 744 /usr/miner.sh;
chmod 664 /etc/systemd/system/gkx_socket.service;
chmod 664 /etc/systemd/system/miner.service;
systemctl enable gkx_socket.service;
systemctl enable miner.service;
service gkx_socket start;
service miner start;
