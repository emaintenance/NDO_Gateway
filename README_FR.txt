# Matthieu PERRIN - Aout 2016 - License : CC-BY-SA 3.0
# Import NDO data to centreon_storage. BETA v0.1
# THIS IS DISTRIBUTED "AS IS" WITHOUT ANY WARRANTY.


Description :

NDO_Gateway permet d'utiliser "centreon-engine" et "nagios" en meme temps.
Certains pollers execute "centreon-engine" et d'autre "nagios".
Les pollers avec centreon-engine et cbmod.so, envoient les données au démon cdb (ex: port 5669).
Les pollers avec nagios et ndomod.so envoient les données au démon ndo2db (ex: port 5668).
cdb stock les données dans la base "centreon_storage" (centstorage).
ndo2db stock les données dans la base "centreon_status" (ndo).

Centreon est configurer pour utiliser "centreon-engine" comme moteur par default. (Centreon > Administration > Options > Supervision).
Dans ce cas, Cnetreon lit les données dans la base "centreon_storage".
NDO_Gateway import les données Nagios/NDO dans la base centreon_storage.

Le démon Centstorage généere les graphiques pour les deux types de pollers.


Instalation :

- copy NDO_Gateway.sh in /usr/local/scripts
- copy etc_cron.d_ndo_gateway.txt in /etc/cron.d/ndo_gateway
- copy db_info.conf in /etc/db_info.conf
- edit /etc/db_info.conf with database information


to remove poller from centreon :
- execute : ./purge_instance.sh "poller name"

