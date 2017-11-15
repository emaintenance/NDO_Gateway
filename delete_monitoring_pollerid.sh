#!/bin/bash
# Matthieu PERRIN - Aout 2017 - License : CC-BY-SA 3.0
# Delete host and service monitoring for pollerid in ${centreon_storage}.
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.


# login information
. /etc/db_info.conf

[ -z $1 ] && echo "Usage : $0 [POLLERID]" && exit

pollerid=$1
db=centstorage

# Delete all service from host in pollerid
query="delete from centstorage.services where host_id in (select host_id from hosts where hosts.instance_id=${pollerid});"
 /usr/bin/mysql -u ${db_user} -h ${db_host} -p${db_passwd} -D ${db} -e "${query}" > /dev/null

# Delete all host in pollerid
query="delete from centstorage.hosts where hosts.instance_id=${pollerid};"
 /usr/bin/mysql -u ${db_user} -h ${db_host} -p${db_passwd} -D ${db} -e "${query}" > /dev/null

