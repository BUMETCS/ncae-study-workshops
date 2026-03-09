$TTL    86400
@       IN      SOA     teamX.net. root.teamX.net. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      <hostname>.
12      IN      PTR     ns1.teamX.net.
7       IN      PTR     db1.teamX.net.
5       IN      PTR     www.teamX.net.