# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to centreon_storage. BETA v0.1
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.

Instalation :

- copy NDO_Gateway.sh in /usr/local/scripts
- copy etc_cron.d_ndo_gateway.txt in /etc/cron.d/ndo_gateway
- copy db_info.conf in /etc/db_info.conf
- edit /etc/db_info.conf with database information


to remove poller from centreon :
- execute : ./purge_instance.sh "poller name"

