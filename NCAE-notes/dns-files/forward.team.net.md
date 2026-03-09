$TTL    86400
@       IN      SOA     teamX.net root (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name
<hostname>>   IN      A       <ip addr>
ns1     IN      A       192.168.X.12
www     IN      A       192.168.X.5
db1     IN      A       192.168.X.7