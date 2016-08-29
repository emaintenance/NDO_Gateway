#!/bin/bash

mkdir -p /usr/local/scripts
cp NDO_Gateway.sh /usr/local/scripts/
chmod +x /usr/local/scripts/*.sh
cp db_info.conf /etc/db_info.conf
cat etc_cron.d_ndo_gateway.txt > /etc/cron.d/ndo_gateway
echo "edit /etc/db_info.conf with database information"
