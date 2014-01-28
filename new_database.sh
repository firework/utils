#! /bin/bash

read -rp "DB Name: " db_name
read -rp "DB User: " db_user
read -rp "DB Pass: " db_pass

mysql -uroot -p -e "CREATE DATABASE ${db_name}; GRANT ALL ON ${db_name}.* TO ${db_user}@localhost IDENTIFIED BY '${db_pass}';"