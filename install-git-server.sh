#!/bin/bash
set -exo pipefail

if [[ ! -d /opt/git ]]; then

# System Settings
printf "fs.file-max = 100000\n" | sudo tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
cat >> /etc/security/limits.conf << EOF
*    soft    nofile  65535
*    hard    nofile  65535
EOF
ulimit -n 1048575

# Basic components
dnf install -y nano git

### Git for Centos 7
# yum install -y https://centos7.iuscommunity.org/ius-release.rpm
# yum install -y git2u-all git2u-gitweb
# git --version

mkdir /opt/git
ln -s /opt/git /git
fi

if ! grep '^$projectroot' /etc/gitweb.conf ; then
    printf '$projectroot = "/opt/git";\n' | sudo tee -a /etc/gitweb.conf
else
    echo '$projectroot already set'
fi


### Journald. Reduce log level /etc/systemd/journald.conf
    #MaxLevelStore=info # default debug
    #MaxLevelSyslog=info # default debug
    ##MaxLevelConsole=notice #default - info #leave as is?
for JLEVEL in MaxLevelStore MaxLevelSyslog ; do
    if grep "^#$JLEVEL" /etc/systemd/journald.conf ; then
        sed -i "s/^#$JLEVEL.*/$JLEVEL=info #default debug/g" /etc/systemd/journald.conf
    elif grep "^$JLEVEL" /etc/systemd/journald.conf ; then
        sed -i "s/^$JLEVEL.*/$JLEVEL=info #default debug/g" /etc/systemd/journald.conf
    else
        exit 1
    fi
done
systemctl restart systemd-journald


### Rsyslog. Reduce log level /etc/rsyslog.conf
cp -n /etc/rsyslog.conf /etc/rsyslog.conf.bak
RLEVELOLD=$( grep '^\*.*/var/log/messages.*' /etc/rsyslog.conf ) #Get original string. This can be different due to server setup even same distro version
echo "Old rsyslog string: $RLEVELOLD"
RLEVELNEW="${RLEVELOLD//info/notice}" # change log level from "info" to "notice"
sed -i "s@^$RLEVELOLD@$RLEVELNEW \#default info@g" /etc/rsyslog.conf #replace old string with mew one
echo "New rsyslog string: $RLEVELNEW"
