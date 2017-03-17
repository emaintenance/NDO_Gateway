#!/bin/bash
# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to ${centreon_storage}. BETA v0.4
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.

# login information
. /etc/db_info.conf

#centreon_status=centreon_status
#centreon_storage=centreon_storage
centreon=centreon
centreon_status=ndo
centreon_storage=centstorage

[ "$1" == "attend" ] && sleep 10

online=$(date +%s --date "30 min ago")



mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "select distinct(instance_id) from ndo.nagios_conninfo where ndo.nagios_conninfo.last_checkin_time > ${online}" > /tmp/instance_id


while read instance; do


####################
# CREATE OBJECTS

# Import poller information
mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe " INSERT IGNORE INTO ${centreon_storage}.instances ( instance_id, name, active_host_checks, active_service_checks, engine, last_alive, running, start_time, version) select nagios_instances.instance_id, nagios_instances.instance_name, 1, 1, 'NDO Gateway', UNIX_TIMESTAMP(last_checkin_time), 1, UNIX_TIMESTAMP(data_start_time), '0.4'  from ${centreon_status}.nagios_conninfo, nagios_instances,  nagios_hoststatus  where nagios_hoststatus.instance_id=nagios_instances.instance_id and nagios_hoststatus.instance_id= ${instance} and data_end_time=0 and UNIX_TIMESTAMP(nagios_conninfo.last_checkin_time) > ${online}; "


# Import host status
mysql -h $db_host  -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT IGNORE INTO ${centreon_storage}.hosts
 ( host_id, name, display_name, address, instance_id, state, output, perfdata, last_check, acknowledged, check_attempt, state_type, next_check, scheduled_downtime_depth, flapping, latency, execution_time, last_state_change)
 select ${centreon}.host.host_id, nagios_hosts.alias, nagios_hosts.display_name, nagios_hosts.address, nagios_hoststatus.instance_id, nagios_hoststatus.current_state, nagios_hoststatus.output, nagios_hoststatus.perfdata, UNIX_TIMESTAMP(nagios_hoststatus.last_check), nagios_hoststatus.problem_has_been_acknowledged, nagios_hoststatus.current_check_attempt,
nagios_hoststatus.state_type,
UNIX_TIMESTAMP(nagios_hoststatus.next_check),
nagios_hoststatus.scheduled_downtime_depth,
nagios_hoststatus.is_flapping,
nagios_hoststatus.latency,
nagios_hoststatus.execution_time,
UNIX_TIMESTAMP(nagios_hoststatus.last_state_change)
from nagios_hoststatus, nagios_hosts, nagios_instances, ${centreon}.host
where nagios_hoststatus.host_object_id=nagios_hosts.host_object_id
and ${centreon}.host.host_name=nagios_hosts.display_name
and nagios_hoststatus.instance_id=${instance}
and UNIX_TIMESTAMP(nagios_hoststatus.last_check) > ${online}; "

# Import service status
mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT IGNORE INTO ${centreon_storage}.services
( host_id, service_id, description, state, output, perfdata, last_check, acknowledged, check_attempt, state_type, next_check, scheduled_downtime_depth, flapping, latency, execution_time, last_state_change)
select host_host_id, service_service_id, nagios_objects.name2, current_state, output, perfdata, UNIX_TIMESTAMP(last_check), problem_has_been_acknowledged, current_check_attempt, state_type, UNIX_TIMESTAMP(next_check), scheduled_downtime_depth, is_flapping, latency, execution_time, UNIX_TIMESTAMP(last_state_change)
from nagios_servicestatus, nagios_objects, ${centreon}.host, ${centreon}.service, ${centreon}.host_service_relation
where service_object_id=nagios_objects.object_id
and ${centreon}.host.host_id=${centreon}.host_service_relation.host_host_id
and ${centreon}.service.service_id=${centreon}.host_service_relation.service_service_id
and ${centreon}.host.host_name=nagios_objects.name1
and ${centreon}.service.service_description=nagios_objects.name2
and ${centreon_status}.nagios_servicestatus.instance_id=${instance}
and UNIX_TIMESTAMP(last_check) > ${online}; "



####################
# UPDATE OBJETS

# Import poller information
mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "UPDATE ${centreon_storage}.instances INNER JOIN  ${centreon_status}.nagios_conninfo ON  ${centreon_storage}.instances.instance_id = ${centreon_status}.nagios_conninfo.instance_id  SET ${centreon_storage}.instances.engine = 'NDO Gateway',  ${centreon_storage}.instances.last_alive =  UNIX_TIMESTAMP(${centreon_status}.nagios_conninfo.last_checkin_time),  ${centreon_storage}.instances.start_time =  UNIX_TIMESTAMP(${centreon_status}.nagios_conninfo.data_start_time),  ${centreon_storage}.instances.version =  '0.4', ${centreon_storage}.instances.running=1 WHERE
 ${centreon_status}.nagios_conninfo.instance_id = ${instance} AND UNIX_TIMESTAMP(${centreon_status}.nagios_conninfo.last_checkin_time) > ${online}; "


# Import host status
mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
UPDATE ${centreon_storage}.hosts
INNER JOIN ${centreon}.host ON ${centreon_storage}.hosts.host_id = ${centreon}.host.host_id
INNER JOIN ${centreon_status}.nagios_hosts ON ${centreon_storage}.hosts.name = ${centreon_status}.nagios_hosts.alias
INNER JOIN ${centreon_status}.nagios_hoststatus ON ${centreon_status}.nagios_hoststatus.host_object_id=${centreon_status}.nagios_hosts.host_object_id
AND ${centreon_storage}.hosts.address = ${centreon_status}.nagios_hosts.address
AND ${centreon}.host.host_name=${centreon_status}.nagios_hosts.display_name
set ${centreon_storage}.hosts.host_id = ${centreon}.host.host_id,
 ${centreon_storage}.hosts.name = ${centreon_status}.nagios_hosts.alias,
 ${centreon_storage}.hosts.display_name =  ${centreon_status}.nagios_hosts.display_name,
 ${centreon_storage}.hosts.address = ${centreon_status}.nagios_hosts.address,
 ${centreon_storage}.hosts.instance_id = ${centreon_status}.nagios_hoststatus.instance_id,
 ${centreon_storage}.hosts.state = ${centreon_status}.nagios_hoststatus.current_state,
 ${centreon_storage}.hosts.output = ${centreon_status}.nagios_hoststatus.output,
 ${centreon_storage}.hosts.perfdata = ${centreon_status}.nagios_hoststatus.perfdata,
 ${centreon_storage}.hosts.last_check = UNIX_TIMESTAMP(${centreon_status}.nagios_hoststatus.last_check),
 ${centreon_storage}.hosts.acknowledged = ${centreon_status}.nagios_hoststatus.problem_has_been_acknowledged,
 ${centreon_storage}.hosts.check_attempt = ${centreon_status}.nagios_hoststatus.current_check_attempt,
 ${centreon_storage}.hosts.state_type = ${centreon_status}.nagios_hoststatus.state_type,
 ${centreon_storage}.hosts.next_check = UNIX_TIMESTAMP(${centreon_status}.nagios_hoststatus.next_check),
 ${centreon_storage}.hosts.scheduled_downtime_depth = ${centreon_status}.nagios_hoststatus.scheduled_downtime_depth,
 ${centreon_storage}.hosts.flapping = ${centreon_status}.nagios_hoststatus.is_flapping,
 ${centreon_storage}.hosts.latency = ${centreon_status}.nagios_hoststatus.latency,
 ${centreon_storage}.hosts.execution_time = ${centreon_status}.nagios_hoststatus.execution_time,
 ${centreon_storage}.hosts.last_state_change = UNIX_TIMESTAMP(${centreon_status}.nagios_hoststatus.last_state_change),
 ${centreon_storage}.hosts.enabled = 1
where ${centreon_status}.nagios_hoststatus.instance_id = ${instance} AND UNIX_TIMESTAMP(nagios_hoststatus.last_check) > ${online}; "

# Import service status
mysql -h $db_host -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
UPDATE ${centreon_storage}.services
INNER JOIN ${centreon}.host ON ${centreon}.host.host_id = ${centreon_storage}.services.host_id
INNER JOIN ${centreon}.service ON ${centreon}.service.service_id = ${centreon_storage}.services.service_id
INNER JOIN ${centreon_status}.nagios_objects ON ${centreon}.host.host_name=${centreon_status}.nagios_objects.name1 AND ${centreon}.service.service_description=nagios_objects.name2
INNER JOIN ${centreon_status}.nagios_servicestatus ON nagios_servicestatus.service_object_id = ${centreon_status}.nagios_objects.object_id
set ${centreon_storage}.services.host_id = ${centreon}.host.host_id,
${centreon_storage}.services.service_id = ${centreon}.service.service_id,
${centreon_storage}.services.description = ${centreon}.service.service_description,
${centreon_storage}.services.state = ${centreon_status}.nagios_servicestatus.current_state,
${centreon_storage}.services.output = ${centreon_status}.nagios_servicestatus.output,
${centreon_storage}.services.perfdata = ${centreon_status}.nagios_servicestatus.perfdata,
${centreon_storage}.services.last_check = UNIX_TIMESTAMP(${centreon_status}.nagios_servicestatus.last_check),
${centreon_storage}.services.acknowledged = ${centreon_status}.nagios_servicestatus.problem_has_been_acknowledged,
${centreon_storage}.services.check_attempt = ${centreon_status}.nagios_servicestatus.current_check_attempt,
${centreon_storage}.services.state_type = ${centreon_status}.nagios_servicestatus.state_type,
${centreon_storage}.services.next_check = UNIX_TIMESTAMP(${centreon_status}.nagios_servicestatus.next_check),
${centreon_storage}.services.scheduled_downtime_depth = ${centreon_status}.nagios_servicestatus.scheduled_downtime_depth,
${centreon_storage}.services.flapping = ${centreon_status}.nagios_servicestatus.is_flapping,
${centreon_storage}.services.latency = ${centreon_status}.nagios_servicestatus.latency,
${centreon_storage}.services.execution_time = ${centreon_status}.nagios_servicestatus.execution_time,
${centreon_storage}.services.last_state_change = UNIX_TIMESTAMP(${centreon_status}.nagios_servicestatus.last_state_change),
${centreon_storage}.services.enabled = 1
where ${centreon_status}.nagios_servicestatus.instance_id = ${instance} AND UNIX_TIMESTAMP(${centreon_status}.nagios_servicestatus.last_check) > ${online}; "


done < /tmp/instance_id
