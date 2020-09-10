#!/bin/bash -x

#https://docs.docker.com/engine/admin/multi-service_container/

#restore default database if new volume mount
if [ ! -f /var/lib/mysql/ibdata1 ]; then
  echo "Restoring backup from /root/mysql.tar.gz"
  tar xzvf /root/mysql.tar.gz -C /
  chown mysql:mysql -R /var/lib/mysql
  echo "Done"
fi

#restore default config if new volume mount
if [ ! -f /etc/asterisk/manager.conf ]; then
  echo "Restoring backup from /root/asterisk-config.tar.gz"
  tar xzvf /root/asterisk-config.tar.gz -C /
  chown asterisk:asterisk -R /etc/asterisk
  echo "Done"
fi

#restore default lib if new volume mount
if [ ! -f /var/lib/asterisk/bin/fwconsole ]; then
  echo "Restoring backup from /root/asterisk-lib.tar.gz"
  tar xzvf /root/asterisk-lib.tar.gz -C /
  chown asterisk:asterisk -R /var/lib/asterisk
  echo "Done"
fi

/etc/init.d/mysql start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start mysql: $status"
  exit $status
fi

fwconsole start
if [ $status -ne 0 ]; then
  echo "Failed to start fwconsole: $status"
  exit $status
fi

#restore backup if exists
# if [ -f /backup/new.tgz ]; then
#   echo "Restoring backup from /backup/new.tgz"
#   php /var/www/html/admin/modules/backup/bin/restore.php --items=all --restore=/backup/new.tgz
#   echo "Done"
# fi
#restart freepbx to load everything fine after restoring backup
# fwconsole stop
# if [ $status -ne 0 ]; then
#   echo "Failed to stop fwconsole: $status"
#   exit $status
# fi
# fwconsole start
# if [ $status -ne 0 ]; then
#   echo "Failed to start fwconsole: $status"
#   exit $status
# fi


/etc/init.d/apache2 start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start apache2: $status"
  exit $status
fi

/run/backup.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start backup.sh: $status"
  exit $status
fi

/run/delete-old-recordings.sh &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start delete-old-recordings: $status"
  exit $status
fi

while /bin/true; do
  ps aux |grep mysqld |grep -q -v grep
  MYSQL_STATUS=$?
  ps aux |grep asterisk |grep -q -v grep
  ASTERISK_STATUS=$?
  ps aux |grep '/run/backup.sh' |grep -q -v grep
  BACKUPSCRIPT_STATUS=$?

  echo "Checking running processes..."
  if [ $MYSQL_STATUS -ne 0 -o $ASTERISK_STATUS -ne 0 -o $BACKUPSCRIPT_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  echo "OK"
  sleep 60
done