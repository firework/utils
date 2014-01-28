#! /bin/bash

read -rp "Domain: " domain
read -rp "Sub-domain: " sub_domain
read -rp "Public folder: " public_folder
read -rp "non-www(Y/n): " is_non_www
read -rp "h5bp(Y/n): " use_h5bp
read -rp "php(Y/n): " is_php
read -rp "company(firework/ftzweb): " company

content=''

if [[ $is_non_www != 'n' && $is_non_www != 'N' ]]
then
  content="
# www to non-www redirect -- duplicate content is BAD
server {
  # don't forget to tell on which port this server listens
  listen 80;

  # listen on the www host
  server_name ${domain};

  # and redirect to the non-www host (declared below)
  return 301 \$scheme://www.${domain}\$request_uri;
}
"
fi

content="$content
server {
  # listen 80 default_server deferred; # for Linux
  listen 80;

  # The host name to respond to
  server_name ${sub_domain}.${domain};

  # Path for static files
  root /srv/${company}/${domain}/${sub_domain}${public_folder};

  # Logs
  error_log  /srv/${company}/${domain}/logs/${sub_domain}.error.log warn;
  access_log /srv/${company}/${domain}/logs/${sub_domain}.access.log main;

  # Index files
  index index.html index.php;

  # Specify a charset
  charset utf-8;

  # Custom 404 page
  error_page 404 /404.html;
"

if [[ $use_h5bp != 'n' && $use_h5bp != 'N' ]]
then
content="$content
  # Include the component config parts for h5bp
  include conf/h5bp.conf;
"
fi

if [[ $is_php != 'n' && $is_php != 'N' ]]
then
content="$content
  # URLs to attempt, including pretty ones.
  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  # Don't log robots.txt or favicon.ico files
  location = /favicon.ico { log_not_found off; access_log off; }
  location = /robots.txt  { log_not_found off; access_log off; }

  # PHP FPM configuration.
  location ~ \.php\$ {
    fastcgi_split_path_info   ^(.+\.php)(.*)$;
    fastcgi_pass              unix:/var/run/php5-fpm.sock;
    fastcgi_index             index.php;
    include                   fastcgi_params;
  }
"
fi

content="$content
  # We don't need .ht files with nginx.
  location ~ /\.ht {
    access_log        off;
    log_not_found     off;
    deny all;
  }
}"

mkdir -p /etc/nginx/sites-available/${domain}
mkdir -p /etc/nginx/sites-enabled/${domain}
echo "$content" > /etc/nginx/sites-available/${domain}/${sub_domain}.conf
ln -s /etc/nginx/sites-available/${domain}/${sub_domain}.conf /etc/nginx/sites-enabled/${domain}/${sub_domain}.conf

mkdir -p /srv/${company}/${domain}/logs
mkdir -p /srv/${company}/${domain}/${sub_domain}
chown -R ${company}:www-data /srv/${company}/${domain}

service nginx reload