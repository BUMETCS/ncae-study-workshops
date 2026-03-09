**SSH keys setup**

ssh-keygen 
-t specifies type. (ex rsa, ecdsa)
-f specifies the path to create it

ssh-copy-id  (copies to the users .ssh authorized keys folder)
-i specifies we will use a specific keyfile location path

1) Create a kyle user on the SSH server
2) From local, ssh-copy-id -i /home/kvandoremalen/.ssh/id_rsa.pub kyle@SSHserver   to import your key into the authorized keys file
3) In /etc/ssh/sshd_config

PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM no

systemctl restart sshd

4) You can also use scp to move ssh keys
scp <what do i wanna copy> <where do i wanna copy to>
scp sandbox@192.168.1.1:/home/sandbox/id_bob_key . 

**Helpful tips:**
1) ssh_config (client configs)
2) sshd_config (server configs)
3) Make sure ssh is allowed through the firewall/router

Options we might want also to change:
Port  -  22 by default
ListenAddress   - ssh service will run on a specific ip, unless its 0.0.0.0 itll listen to any ip
HostKey  - which key we want used?
PermitRootLogin no (or yes)

File permissions

private key is 600
public key is 644
.ssh folder is 700
authorized_keys file is 600
known_hosts file is 644

All need to be owned by the actual user


**Hardening SSH**

PasswordAuthentication no               prevents brute-force attacks
PubkeyAuthentication yes                make sure you can use ssh keys
PermitRootLogin no                      prevents root access being forced
PermitEmptyPasswords no
MaxAuthTries 3

**Hardening FTP**

anonymous_enable=NO
local_enable=YES
write_enable=YES
local_root=/mnt/files
chroot_local_user=YES
allow_writeable_chroot=YES
listen=YES
listen_ipv6=NO
pam_service_name=vsftpd

userlist_enable=YES             this allows the use of the userlist in the first place
userlist_deny=NO                means all users in the userlist will be allowed to login

pam_service_name=vsftpd         Lets you login with passwords? otherwise it doesnt work for e
pasv_enable=YES         enables passive mode. Lets you transfer data when behind a firewall or NAT
When yes, it opens a random port range for the connection so the user can transfer files

pasv_min_port=30000
pasv_max_port=30100

**Allow SSH/FTP through firewall**

firewalld:

firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --zone=public --add-port=30000-30100/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all


selinux:

setsebool -P ftpd_full_access 1
setsebool -P ftpd_use_passive_mode 1
semanage port -a -t ftp_port_t -p tcp 30000-30100