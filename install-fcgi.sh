#!/bin/bash
# fcgi is needed for Nginx to work with cGit and GitWeb
set -exo pipefail

dnf install epel-release -y
dnf install spawn-fcgi fcgiwrap -y

cp -n /etc/sysconfig/spawn-fcgi /etc/sysconfig/spawn-fcgi.bak
cat > /etc/sysconfig/spawn-fcgi <<- 'EOF'
FCGI_SOCKET=/var/run/fcgiwrap.socket
FCGI_PROGRAM=/usr/sbin/fcgiwrap
FCGI_USER=nginx
FCGI_GROUP=nginx
FCGI_EXTRA_OPTIONS="-M 0700"
OPTIONS="-u $FCGI_USER -g $FCGI_GROUP -s $FCGI_SOCKET -S $FCGI_EXTRA_OPTIONS -F 1 -P /var/run/spawn-fcgi.pid -- $FCGI_PROGRAM"
EOF

# systemctl enable --now spawn-fcgi
systemctl start spawn-fcgi && systemctl enable spawn-fcgi && systemctl status spawn-fcgi


cat > /etc/nginx/conf.d/fcgiwrap.conf <<- 'EOF'
# Perl-FastCGI server
# network or unix domain socket configuration

upstream fcgiwrap {
        server unix:/var/run/fcgiwrap.socket;
}
EOF

# SELinux: Allow Nginx to write in socket
dnf install policycoreutils-python-utils
grep nginx /var/log/audit/audit.log | audit2allow -m nginx
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
semodule -i nginx.pp

# Allow Nginx to read repos
setfacl -R -m u:nginx:rx,d:u:nginx:rx /opt/git
setfacl -R -x u:nginx,d:u:nginx /opt/git/{prl-prod-secure.git,prl-staging-secure.git,prl-jenkins-U05.git}

#https://serverfault.com/questions/346105/django-nginx-fastcgi-running-via-unix-sockets-permission-problems
