#!/bin/bash
apt-get update
apt-get install -y automake build-essential autoconf pkg-config libcurl4-openssl-dev libjansson-dev libssl-dev libgmp-dev
sysctl -w vm.nr_hugepages=$((`grep -c ^processor /proc/cpuinfo` * 3))
git clone https://github.com/tpruvot/cpuminer-multi /root/cpuminer-multi && cd /root/cpuminer-multi/ && ./autogen.sh
if [ ! "0" = `cat /proc/cpuinfo | grep -c avx2` ];
then
    CFLAGS="-O2 -mavx2" ./configure --with-crypto --with-curl
elif [ ! "0" = `cat /proc/cpuinfo | grep -c avx` ];
then
    CFLAGS="-O2 -mavx" ./configure --with-crypto --with-curl
else
    CFLAGS="-march=native" ./configure --with-crypto --with-curl
fi
make clean && make

printf "#!/bin/bash\n/root/cpuminer-multi/cpuminer -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u greatbnt@gmail.com -p x --thread=`eval grep -c ^processor /proc/cpuinfo`" > /root/miner.sh
printf "[Unit]\n\n[Service]\nExecStart=/root/miner.sh\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/miner.service
chmod +x /root/miner.sh
chmod 744 /root/miner.sh
chmod 664 /etc/systemd/system/miner.service
systemctl enable miner.service
service miner start
