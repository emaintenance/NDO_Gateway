#!/bin/bash
# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to centreon_storage. BETA v0.1
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.

# login information
. /etc/db_info.conf
centreon_status=centreon_status
centreon_storage=centreon_storage

#online=$(date +%s --date "15 min ago")

# Import downtime history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
REPLACE INTO ${centreon_storage}.downtimes 
(entry_time, host_id, service_id, author, cancelled, comment_data, end_time, fixed, instance_id, start_time, started, type )
select UNIX_TIMESTAMP(nagios_downtimehistory.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_downtimehistory.author_name, nagios_downtimehistory.was_cancelled, nagios_downtimehistory.comment_data, UNIX_TIMESTAMP(nagios_downtimehistory.scheduled_end_time), nagios_downtimehistory.is_fixed, nagios_downtimehistory.instance_id, UNIX_TIMESTAMP(nagios_downtimehistory.scheduled_start_time), nagios_downtimehistory.was_started, 1
from nagios_downtimehistory, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_downtimehistory.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2;"
#and UNIX_TIMESTAMP(entry_time) > ${online}; "


# Import acknowledgements history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
REPLACE INTO ${centreon_storage}.acknowledgements 
(entry_time, host_id, service_id, author, comment_data, instance_id, notify_contacts, persistent_comment, state, sticky, type )
select UNIX_TIMESTAMP(nagios_acknowledgements.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_acknowledgements.author_name, nagios_acknowledgements.comment_data, nagios_acknowledgements.instance_id, nagios_acknowledgements.notify_contacts, nagios_acknowledgements.persistent_comment, nagios_acknowledgements.state, nagios_acknowledgements.is_sticky, nagios_acknowledgements.acknowledgement_type
from nagios_acknowledgements, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_acknowledgements.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2";
#and UNIX_TIMESTAMP(entry_time) > ${online}; "

# Import comments history
mysql -u ${db_user} -p${db_passwd} -D ${centreon_status} -sNe "
REPLACE INTO ${centreon_storage}.comments 
(entry_time, host_id, service_id, author, data, instance_id, persistent, source, entry_type, type, expire_time, expires)
select UNIX_TIMESTAMP(nagios_comments.entry_time), centreon.host_service_relation.host_host_id, centreon.host_service_relation.service_service_id, nagios_comments.author_name, nagios_comments.comment_data, nagios_comments.instance_id, nagios_comments.is_persistent, nagios_comments.comment_source, nagios_comments.entry_type, 900, 0, 0
from nagios_comments, nagios_objects , centreon.host, centreon.service, centreon.host_service_relation 
where nagios_comments.object_id=nagios_objects.object_id
and centreon.host.host_id=centreon.host_service_relation.host_host_id 
and centreon.service.service_id=centreon.host_service_relation.service_service_id 
and centreon.host.host_name=nagios_objects.name1 
and centreon.service.service_description=nagios_objects.name2";
#and nagios_comments.entry_type=4";
#and UNIX_TIMESTAMP(entry_time) > ${online}; "


