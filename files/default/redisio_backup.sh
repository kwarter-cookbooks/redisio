#!/bin/bash

## Set variables 
AppName=redis
TodayDate=`date +"%d/%b/%g %r"`
DateStamp=`date +%Y%m%d%H%M`
CurrentTime=`date +"%r"`
AppBinPath="/usr/local/bin"
LogFile="/tmp/$AppName-backup-$DateStamp_$CurrentTime.log"
IsOK=0
CmdStatus=""
BackupPath="/var/backups"
BackupFileName="`hostname`.$AppName.$DateStamp"
AppDataDir="/var/lib/redis"

find ${BackupPath}/*.tar* -atime +7 -exec rm {} \;
find ${BackupPath}/dump* -atime +7 -exec rm {} \;


echo "save" | redis-cli
LatestCopy=`ls -rt ${AppDataDir} | tail -1`
sudo cp ${AppDataDir}/${LatestCopy} ${BackupPath}/${LatestCopy}.${DateStamp}; \
sudo tar -czvf ${BackupPath}/${BackupFileName}.tar -C ${BackupPath} ${LatestCopy}.${DateStamp}; \

s3cmd put ${BackupPath}/${BackupFileName}.tar s3://backups.kwarter.com/`hostname |cut -d"." -f2`/${AppName}/
