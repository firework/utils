#!/bin/bash

BASEDIR="$(dirname $0)"/../

cd $BASEDIR

rm -rf app/config
git checkout app/config

mysql -uroot -proot -e "DROP DATABASE laravel ; CREATE DATABASE laravel"

composer install
git checkout app/config/app.php

php artisan platform:install
