#!/bin/sh
# Refresh local developer DB from SCQA database
PATH=${PATH}:/usr/local/mysql/bin
MYSQLCMD="mysql -uweb -p2clever4u"
echo 'Dumping QA DB ... (requires paro password for scqa)'
mysqldump --single-transaction --master-data=0 \
          -uparo -p -hhp.clevermachine.com paqa >/tmp/scqa$$.sql 
if [ $? -ne 0 ]; then
	echo mysqldump failed, aborting...
	exit
fi
echo Fixing DB dump ...
perl -ni -e 'print unless m/SQL SECURITY DEFINER/;'  /tmp/scqa$$.sql
echo Dropping local DB ...
echo 'drop database pa' | $MYSQLCMD
echo 'Loading DB Dump into local DB ...'
echo 'create database pa default charset="utf8"' | $MYSQLCMD
$MYSQLCMD pa < /tmp/scqa$$.sql
echo Setting all clevermachine.com users as superUser ...
echo "update loginuser set superuser=1 where login like '%clevermachine.com'" | $MYSQLCMD pa
echo Setting blank password hash for all clevermachine.com users ...
echo "update loginuser set hashedPassword='w9cCpjl2210NuEpfvZJjllt0f09lmEk97-_I_IUwEwdPjJSUbaJixg==' where login like '%clevermachine.com'" | $MYSQLCMD pa
echo Done.
