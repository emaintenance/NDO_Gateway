#!/bin/bash

mkdir -p /usr/local/scripts
cp NDO_Gateway.sh /usr/local/scripts/
chmod +x /usr/local/scripts/*.sh
cp db_info.conf /etc/db_info.conf
echo "edit /etc/db_info.conf with database information"