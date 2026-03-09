$TTL    86400
@       IN      SOA     teamX.ncaecybergames.org root (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      $name
<hostname>   IN      A   <host ip>
ns1     IN      A       172.18.13.X
www     IN      A       172.18.13.X
files   IN      A       172.18.14.X
shell   IN      A       172.18.14.X