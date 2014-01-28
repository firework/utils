#!/bin/bash

BASEDIR="$(dirname $0)"/../

cd $BASEDIR

git stash
git pull origin master
rm -rf app/config
git checkout app/config

mysql -uroot -p -e "DROP DATABASE towertours ; CREATE DATABASE towertours; GRANT ALL ON towertours.* TO towertours@localhost"

composer install
git checkout app/config/app.php
git stash apply

php artisan platform:install
php artisan towertours:seed

chown -R firework:www-data .
chmod 777 -R app/storage public/assets/cache public/services
