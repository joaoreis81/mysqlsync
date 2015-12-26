#!/bin/bash

MASTER_USER=root
MASTER_PASS=rootpasswd
MASTER_HOST=192.168.0.10
SLAVE_USER=root
SLAVE_PASS=slavepasswd
REP_USER=slave
REP_PASS=replicationpasswd
DATABASE=dbispconfig

/usr/bin/mysql -u$MASTER_USER -h $MASTER_HOST mysql -p$MASTER_PASS -e 'FLUSH TABLES WITH READ LOCK;'
LOGPOS=`/usr/bin/mysql -u$MASTER_USER -h $MASTER_HOST mysql -p$MASTER_PASS -e 'SHOW MASTER STATUS'|grep mysql-bin`
LOG=$(echo $LOGPOS | cut -f1 -d" ")
POS=$(echo $LOGPOS | cut -f2 -d" ")
/usr/bin/mysqldump -B -p$MASTER_PASS -u$MASTER_USER -h$MASTER_HOST --add-drop-database $DATABASE > /tmp/"$DATABASE".sql
/usr/bin/mysql -u$MASTER_USER -h $MASTER_HOST mysql -p$MASTER_PASS -e 'UNLOCK TABLES;'
/usr/bin/mysql -u$SLAVE_USER mysql -p$SLAVE_PASS -e 'STOP SLAVE;'
/usr/bin/mysql -u$SLAVE_USER mysql -p$SLAVE_PASS -e 'RESET SLAVE;'
/usr/bin/mysql -u$SLAVE_USER -p$SLAVE_PASS < /tmp/"$DATABASE".sql
/usr/bin/mysql -u$SLAVE_USER -p$SLAVE_PASS -e "CHANGE MASTER TO master_host='$MASTER_HOST', master_user='$REP_USER', master_password='$REP_PASS', master_log_file='$LOG', master_log_pos=$POS;"
#echo -e "CHANGE MASTER TO master_host='$MASTER_HOST', master_user='$REP_USER', master_password='$REP_PASS', master_log_file='$LOG', master_log_pos=$POS;"
/usr/bin/mysql -u$SLAVE_USER -p$SLAVE_PASS -e 'START SLAVE'
#/usr/bin/mysql -u$SLAVE_USER -p$SLAVE_PASS -e 'SHOW SLAVE STATUS\G'
