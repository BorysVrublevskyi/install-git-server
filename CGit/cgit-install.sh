#!/bin/bash
# Deploy CGit on Centos 8
# Place cgitrc and cgit-uberspace-mod.css near this script to autoconfigure
set -exo pipefail

command -v highlight || yum install make gcc-c++ openssl-devel highlight python3-pygments -y
python3 -m pip install -U pip markdown

cd /tmp
# For latest version visit https://git.zx2c4.com/cgit/refs/tags
wget -O cgit.tar.gz https://git.zx2c4.com/cgit/snapshot/cgit-1.2.3.tar.xz
mkdir -p cgit
tar -xvf cgit.tar.gz --strip-components=1 -C cgit
cd ./cgit
make get-git
mkdir -p /var/www/cgit
sed -i 's@^CGIT_SCRIPT_PATH.*www.*@CGIT_SCRIPT_PATH = /var/www/cgit@g' Makefile
make # make NO_LUA=1
make -j"$(nproc)" install # make install

cp -n "$(pwd)/cgitrc" /etc/cgitrc || true
cp -n "$(pwd)/cgit-uberspace-mod.css" /var/www/cgit/cgit-uberspace-mod.css || true

if [ -d /var/www/cgit/filters ]; then
    cp -r ./filters /var/www/cgit/
    # Switch to highlight v3 in syntax-highlighting.sh
    sed -i 's/^exec highlight --force -f -I -X -S/#exec highlight --force -f -I -X -S/' /var/www/cgit/filters/syntax-highlighting.sh
    sed -i '/^#.*exec\shighlight.*xhtml /s/^#//' /var/www/cgit/filters/syntax-highlighting.sh
fi

rm -rf /tmp/cgit*
clear

echo "For more info read local cgitrc.5.txt or web https://git.zx2c4.com/cgit/tree/cgitrc.5.txt"

# https://git.zx2c4.com/cgit/about/
# http://www.christophbrill.de/en/posts/nginx-cgit-in-a-subfolder/
# https://jmahler.github.io/git/2013/06/29/cgit.html
