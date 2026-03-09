**Persistence Hunting**

When hunting, check the following:

**Login shell**

~/.bashrc
/etc/bash.bashrc
/etc/profile
/etc/profile.d/*
~/.profile
~/.bash_profile
~/.bash_login

/etc/bash.bash_logout
~/.bash_logout 


**MOTD**

/etc/update-motd.d/*
/etc/motd 

**Crons**

Also check /lib/systemd/system/cron.service

**SSHD config**

/lib/systemd/system/ssh.service
/etc/ssh/sshd_config

**systemd --user**

/etc/systemd/user.conf
all paths in: "systemd-analyze unit-paths --user":
/lib/systemd/user/*
/etc/systemd/user/*

**User accounts**

/etc/gshadow
/etc/passwd
/etc/groups

/etc/sudoers
/etc/sudoers.d/
/etc/shadow
~/.ssh/authorized_keys


**Web server**

/var/www/html/bad.php
/etc/nginx
/etc/apache2

**Systemd**

/etc/systemd/system.conf
All paths in "systemd-analyze unit-paths":
/lib/systemd/system/*
/etc/systemd/system/*

**Systemd generators**

/etc/init.d/*
/etc/rc.local

/etc/systemd/system-generators/*
/usr/local/lib/systemd/system-generators/*
/lib/systemd/system-generators/*

