#!/bin/bash
set -eo pipefail

cd /opt/git
read -r -p "Enter Name for the new git repo: " REPONAME
REPONAME=$(echo "$REPONAME" | sed "s/ /_/g" | sed "s/\.git$//g")
REPODIR="$REPONAME.git"
git init --bare --shared ./$REPODIR

read -r -p "Enter Description for the new git repo: " REPODESCR
echo "$REPODESCR" > ./$REPODIR/description

### Assign AD group to repos
# chgrp -R sec-dev ./$REPODIR

### Add tech accounts to allow access to the repos
# # setfacl -R -m u:user01:rx,d:u:user01:rx ./$REPODIR
# while true; do
#     read -p "Do we need to add read+execute rights for the 'user01' to this repo? It's using in Crucible. [Y]es, [N]o " yn
#     case $yn in
#         [Yy]* ) setfacl -R -m u:user01:rx,d:u:user01:rx ./$REPODIR; break;;
#         [Nn]* ) break;;
#         * ) echo "Please answer yes or no.";;
#     esac
# done

# # setfacl -R -m u:user02:rx,d:u:user02:rx ./$REPODIR
# while true; do
#     read -p "Do we need to add read+execute rights for the user 'user02' to this repo? It's using in Jenkins' jobs. [Y]es, [N]o " yn
#     case $yn in
#         [Yy]* ) setfacl -R -m u:user02:rx,d:u:user02:rx ./$REPODIR; break;;
#         [Nn]* ) break;;
#         * ) echo "Please answer yes or no.";;
#     esac
# done
