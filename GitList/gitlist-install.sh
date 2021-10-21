#!/bin/bash
# Deploy GitList on Centos 8
set -exo pipefail

dnf install php-fpm php-json php-xml unzip -y
nano /etc/php-fpm.d/www.conf # set user and group to nginx
cd /var/www/
wget -O gitlist.zip https://github.com/patrikx3/gitlist/releases/latest/download/p3x-gitlist-v2020.4.111.zip
unzip gitlist.zip -d ./gitlist
rm -f ./gitlist.zip

#chmod 777 /var/www/gitlist/cache # need to optimize acess level
chown -R nginx. /var/www/gitlist/
chcon -Rvt httpd_sys_rw_content_t /var/www/gitlist/cache

exit 0 # Do not proceed commands below

### For using with domain name ###
cat > /etc/nginx/conf.d/gitlist.conf <<- 'EOF'
server {
        listen   80;

        root /var/www/gitlist/public;
        index index.php index.html index.htm;
        server_name  testgit testgit.justanswer.local;

#        location / {
#               autoindex on;
#               try_files $uri $uri/ /index.php;
#        }

        error_page 404 /404.html;
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
              root /usr/share/nginx/www;
        }

        location ~ .php$ {
                try_files $uri =404;
                fastcgi_pass php-fpm;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }

        location / {
                autoindex on;
                set $redirect_url $uri;
                try_files $uri $uri/ /index.php$is_args$query_string;
        }

#       location = /index.php {
#               include snippets/fastcgi-php.conf;
#               fastcgi_param SCRIPT_FILENAME $request_filename;
#               fastcgi_pass php-fpm;
#       }

}
EOF

# https://github.com/patrikx3/gitlist/blob/master/artifacts/gitlist.patrikx3.com.conf
# https://github.com/patrikx3/gitlist/blob/master/INSTALL.md
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-managing_confined_services-the_apache_http_server-types






