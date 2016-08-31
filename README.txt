# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to centreon_storage. BETA v0.1
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.


Description :

NDO_Gateway allow Using "centreon-engine" and "nagios" in same time.
Some pollers executing "centreon-engine" and some other "nagios".
Pollers with centreon-engine and cbmod.so, send data to cdb daemon (ex: port 5669).
Pollers with nagios anf ndomod.so send data to ndo2db daemon (ex: port 5668).
cdb store data in "centreon_storage" database (centstorage).
ndo2db store data in "centreon_status" database (ndo).

Centreon is configuraing to use "centreon-engine" as default engine. (Centreon > Administration > Options > Monitoring).
In this case, Cnetreon read data from "centreon_storage" database.
NDO_Gateway import Nagios/NDO data to centreon_storage database.

Centstorage deamon generate graph for both pollers engine.


Instalation :

- copy NDO_Gateway.sh in /usr/local/scripts
- copy etc_cron.d_ndo_gateway.txt in /etc/cron.d/ndo_gateway
- copy db_info.conf in /etc/db_info.conf
- edit /etc/db_info.conf with database information


to remove poller from centreon :
- execute : ./purge_instance.sh "poller name"

