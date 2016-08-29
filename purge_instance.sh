#!/bin/bash

. /etc/db_info.conf

poller=$1

#id=$(mysql -u ${db_user} -p${db_passwd} -D centreon_storage -sNe "select instance_id from instances where name='${poller}';")

mysql -u ${db_user} -p${db_passwd} -D centreon_storage -sNe "delete from hosts where instance_id = (select instance_id from instances where instances.name='${poller}' );"
mysql -u ${db_user} -p${db_passwd} -D centreon_storage -sNe "delete FROM services WHERE host_id = ( SELECT hosts.host_id FROM hosts, instances where hosts.host_id and hosts.instance_id=instances.instance_id and instances.name='${poller}' );"

exit

