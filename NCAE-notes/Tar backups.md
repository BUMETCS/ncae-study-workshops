Tar backups

dns:

tar czvf /backups/dns-backup.tar.gz /etc/named.conf /etc/bind /var/named /usr/sbin/named

local users:

tar czvf /backups/local-user-backup.tar.gz /etc/passwd /etc/shadow /etc/group /etc/gshadow

samba: 

tar czvf /backups/smb-backup.tar.gz /etc/samba /var/lib/samba /etc/samba/smb.conf /etc/samba/smbusers /var/lib/samba/private/smbpasswd



restore:

sudo tar --overwrite -xzf $COPY_TO_PATH/$NEW_TAR_NAME -C /