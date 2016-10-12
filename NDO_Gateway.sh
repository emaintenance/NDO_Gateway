#!/bin/bash
# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to centreon_storage. BETA v0.2
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.

# login information
. /etc/db_info.conf
#centreon_status=centreon_status
#centreon_storage=centreon_storage

[ "$1" == "attend" ] && sleep 10

online=$(date +%s --date "10 min ago")


####################
# CREATE OBJECTS

# Import poller information
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe " INSERT IGNORE INTO ${centreon_storage}.instances ( instance_id, name, active_host_checks, active_service_checks, engine, last_alive, running, start_time, version) select nagios_instances.instance_id, nagios_instances.instance_name, 1, 1, 'NDO Gateway', UNIX_TIMESTAMP(last_checkin_time), 1, UNIX_TIMESTAMP(data_start_time), '0.2'  from ${centreon_status}.nagios_conninfo, nagios_instances,  nagios_hoststatus  where nagios_hoststatus.instance_id=nagios_instances.instance_id and nagios_hoststatus.instance_id=nagios_conninfo.instance_id and data_end_time=0 and UNIX_TIMESTAMP(nagios_conninfo.last_checkin_time) > ${online}; "


# Import host status
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT IGNORE INTO ${centreon_storage}.hosts
 ( host_id, name, display_name, address, instance_id, state, output, perfdata, last_check, acknowledged, check_attempt, state_type, next_check, scheduled_downtime_depth, flapping, latency, execution_time, last_state_change)
 select centreon.host.host_id, nagios_hosts.alias, nagios_hosts.display_name, nagios_hosts.address, nagios_hoststatus.instance_id, nagios_hoststatus.current_state, nagios_hoststatus.output, nagios_hoststatus.perfdata, UNIX_TIMESTAMP(nagios_hoststatus.last_check), nagios_hoststatus.problem_has_been_acknowledged, nagios_hoststatus.current_check_attempt,
nagios_hoststatus.state_type,
UNIX_TIMESTAMP(nagios_hoststatus.next_check),
nagios_hoststatus.scheduled_downtime_depth,
nagios_hoststatus.is_flapping,
nagios_hoststatus.latency,
nagios_hoststatus.execution_time,
UNIX_TIMESTAMP(nagios_hoststatus.last_state_change)
from nagios_hoststatus, nagios_hosts, nagios_instances, centreon.host
where nagios_hoststatus.host_object_id=nagios_hosts.host_object_id
and centreon.host.host_name=nagios_hosts.display_name
and nagios_hoststatus.instance_id=nagios_instances.instance_id
and UNIX_TIMESTAMP(nagios_hoststatus.last_check) > ${online}; "

# Import service status
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT IGNORE INTO ${centreon_storage}.services 
( host_id, service_id, description, state, output, perfdata, last_check, acknowledged, check_attempt, state_type, next_check, scheduled_downtime_depth, flapping, latency, execution_time, last_state_change) 
select host_host_id, service_service_id, nagios_objects.name2, current_state, output, perfdata, UNIX_TIMESTAMP(last_check), problem_has_been_acknowledged, current_check_attempt, state_type, UNIX_TIMESTAMP(next_check), scheduled_downtime_depth, is_flapping, latency, execution_time, UNIX_TIMESTAMP(last_state_change)
from nagios_servicestatus, nagios_objects, centreon.host, centreon.service, centreon.host_service_relation  
where service_object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2
and UNIX_TIMESTAMP(last_check) > ${online}; "


####################
# UPDATE OBJETS

# Import poller information
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "UPDATE centreon_storage.instances INNER JOIN  centreon_status.nagios_conninfo ON  centreon_storage.instances.instance_id = centreon_status.nagios_conninfo.instance_id  SET centreon_storage.instances.engine = 'NDO Gateway',  centreon_storage.instances.last_alive =  UNIX_TIMESTAMP(centreon_status.nagios_conninfo.last_checkin_time),  centreon_storage.instances.start_time =  UNIX_TIMESTAMP(centreon_status.nagios_conninfo.data_start_time),  centreon_storage.instances.version =  '0.2' WHERE UNIX_TIMESTAMP(centreon_status.nagios_conninfo.last_checkin_time) > ${online}; " 


# Import host status
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
UPDATE centreon_storage.hosts
INNER JOIN centreon.host ON centreon_storage.hosts.host_id = centreon.host.host_id
INNER JOIN centreon_status.nagios_hosts ON centreon_storage.hosts.name = centreon_status.nagios_hosts.alias 
INNER JOIN centreon_status.nagios_hoststatus ON centreon_status.nagios_hoststatus.host_object_id=centreon_status.nagios_hosts.host_object_id
AND centreon_storage.hosts.address = centreon_status.nagios_hosts.address
AND centreon.host.host_name=centreon_status.nagios_hosts.display_name
set centreon_storage.hosts.host_id = centreon.host.host_id,
 centreon_storage.hosts.name = centreon_status.nagios_hosts.alias,
 centreon_storage.hosts.display_name =  centreon_status.nagios_hosts.display_name,
 centreon_storage.hosts.address = centreon_status.nagios_hosts.address,
 centreon_storage.hosts.instance_id = centreon_status.nagios_hoststatus.instance_id,
 centreon_storage.hosts.state = centreon_status.nagios_hoststatus.current_state,
 centreon_storage.hosts.output = centreon_status.nagios_hoststatus.output,
 centreon_storage.hosts.perfdata = centreon_status.nagios_hoststatus.perfdata,
 centreon_storage.hosts.last_check = UNIX_TIMESTAMP(centreon_status.nagios_hoststatus.last_check),
 centreon_storage.hosts.acknowledged = centreon_status.nagios_hoststatus.problem_has_been_acknowledged,
 centreon_storage.hosts.check_attempt = centreon_status.nagios_hoststatus.current_check_attempt,
 centreon_storage.hosts.state_type = centreon_status.nagios_hoststatus.state_type,
 centreon_storage.hosts.next_check = UNIX_TIMESTAMP(centreon_status.nagios_hoststatus.next_check),
 centreon_storage.hosts.scheduled_downtime_depth = centreon_status.nagios_hoststatus.scheduled_downtime_depth,
 centreon_storage.hosts.flapping = centreon_status.nagios_hoststatus.is_flapping,
 centreon_storage.hosts.latency = centreon_status.nagios_hoststatus.latency,
 centreon_storage.hosts.execution_time = centreon_status.nagios_hoststatus.execution_time,
 centreon_storage.hosts.last_state_change = UNIX_TIMESTAMP(centreon_status.nagios_hoststatus.last_state_change)
where UNIX_TIMESTAMP(nagios_hoststatus.last_check) > ${online}; "

# Import service status
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
UPDATE centreon_storage.services
INNER JOIN centreon.host ON centreon.host.host_id = centreon_storage.services.host_id
INNER JOIN centreon.service ON centreon.service.service_id = centreon_storage.services.service_id
INNER JOIN centreon_status.nagios_objects ON centreon.host.host_name=centreon_status.nagios_objects.name1 AND centreon.service.service_description=nagios_objects.name2
INNER JOIN centreon_status.nagios_servicestatus ON nagios_servicestatus.service_object_id = centreon_status.nagios_objects.object_id
set centreon_storage.services.host_id = centreon.host.host_id, 
centreon_storage.services.service_id = centreon.service.service_id,
centreon_storage.services.description = centreon.service.service_description,
centreon_storage.services.state = centreon_status.nagios_servicestatus.current_state,
centreon_storage.services.output = centreon_status.nagios_servicestatus.output,
centreon_storage.services.perfdata = centreon_status.nagios_servicestatus.perfdata,
centreon_storage.services.last_check = UNIX_TIMESTAMP(centreon_status.nagios_servicestatus.last_check),
centreon_storage.services.acknowledged = centreon_status.nagios_servicestatus.problem_has_been_acknowledged,
centreon_storage.services.check_attempt = centreon_status.nagios_servicestatus.current_check_attempt,
centreon_storage.services.state_type = centreon_status.nagios_servicestatus.state_type,
centreon_storage.services.next_check = UNIX_TIMESTAMP(centreon_status.nagios_servicestatus.next_check),
centreon_storage.services.scheduled_downtime_depth = centreon_status.nagios_servicestatus.scheduled_downtime_depth,
centreon_storage.services.flapping = centreon_status.nagios_servicestatus.is_flapping,
centreon_storage.services.latency = centreon_status.nagios_servicestatus.latency,
centreon_storage.services.execution_time = centreon_status.nagios_servicestatus.execution_time,
centreon_storage.services.last_state_change = UNIX_TIMESTAMP(centreon_status.nagios_servicestatus.last_state_change)
where UNIX_TIMESTAMP(centreon_status.nagios_servicestatus.last_check) > ${online}; "


####################
# UPDATE COMMENT


# Import downtime history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT INTO ${centreon_storage}.downtimes 
(entry_time, host_id, service_id, author, cancelled, comment_data, end_time, fixed, instance_id, start_time, started, type )
select UNIX_TIMESTAMP(nagios_downtimehistory.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_downtimehistory.author_name, nagios_downtimehistory.was_cancelled, nagios_downtimehistory.comment_data, UNIX_TIMESTAMP(nagios_downtimehistory.scheduled_end_time), nagios_downtimehistory.is_fixed, nagios_downtimehistory.instance_id, UNIX_TIMESTAMP(nagios_downtimehistory.scheduled_start_time), nagios_downtimehistory.was_started, 1
from nagios_downtimehistory, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_downtimehistory.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2
and UNIX_TIMESTAMP(entry_time) > ${online}; "


# Import acknowledgements history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT INTO ${centreon_storage}.acknowledgements 
(entry_time, host_id, service_id, author, comment_data, instance_id, notify_contacts, persistent_comment, state, sticky, type )
select UNIX_TIMESTAMP(nagios_acknowledgements.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_acknowledgements.author_name, nagios_acknowledgements.comment_data, nagios_acknowledgements.instance_id, nagios_acknowledgements.notify_contacts, nagios_acknowledgements.persistent_comment, nagios_acknowledgements.state, nagios_acknowledgements.is_sticky, nagios_acknowledgements.acknowledgement_type
from nagios_acknowledgements, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_acknowledgements.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2
and UNIX_TIMESTAMP(entry_time) > ${online}; "

# Import comments history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
INSERT INTO ${centreon_storage}.comments 
(entry_time, host_id, service_id, author, data, instance_id, persistent, source, entry_type, type, expire_time, expires)
select UNIX_TIMESTAMP(nagios_comments.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_comments.author_name, nagios_comments.comment_data, nagios_comments.instance_id, nagios_comments.is_persistent, nagios_comments.comment_source, nagios_comments.entry_type, 900, 0, 0
from nagios_comments, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_comments.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2
and UNIX_TIMESTAMP(entry_time) > ${online}; "


