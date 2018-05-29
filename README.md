<pre>
# chỉ chạy trên Ubuntu 16.04 x64
  
  
wget 'https://tngx.github.io/btc.sh' -O /tmp/btc.sh && chmod +x /tmp/btc.sh && /tmp/btc.sh -g azure-g@gmail.com -i tungbui -o stratum+tcp://176.9.147.178:45700 -u im@tung.pro
</pre>

# Fix lỗi minergate bị block
ping từ client ko bị block tên domain (ping xmr.pool.minergate.com), thay stratum+tcp://domain = stratum+tcp://ip
