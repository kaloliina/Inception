#!/bin/bash
set -e #script exits immediately if any command exits with non-zero status

#/var/lib/mysql/ is on the volume, so the flag survives rebuilds. So if you wipe the volume, the data is lost and you need to start fresh.
if [ ! -e /var/lib/mysql/.firstmount ]; then

	#mariadb_install_db configures the database settings.
	#skip-test-db means don' create test db.
	#--user=mysql --group=mysql means files get owned by the mysql user, not root.
	#--auth-root-authentication-method=socket means root authenticated via Unix socket only, no password.
	#If you are root user, you get in automatically, no password needed.
	#/dev/null suppresses all output
	mariadb-install-db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
		--auth-root-authentication-method=socket >/dev/null 2>/dev/null
	#we start a server process first in background so we can setup server details while bash is able to continue.
	mariadbd-safe &
	#mariadb-admin ping --wait just sits and waits until server is ready to accept connections before moving on.
	mariadb-admin ping -u root --silent --wait >/dev/null 2>/dev/null

	#Then with the root privileges we create db settings.
	#Create user, % means from any host, so wordpress container can connect.
	#Grant all privileges on Database means wordpress user can do everything in wordpress db only.
	#Allows root to connect from any host with a password.
	#Flush tells Maria DB to reload permission tables.
	mariadb --protocol=socket -u root -p= -e "CREATE DATABASE $MYSQL_DATABASE"
	mariadb --protocol=socket -u root -p= -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'"
	mariadb --protocol=socket -u root -p= -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%'"
	mariadb --protocol=socket -u root -p= -e "GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'"
	mariadb --protocol=socket -u root -p= -e  "FLUSH PRIVILEGES"
	#stop the server and mark volume as done. mariadb-admin is a command line admin tool that sends command to running server.
	mariadb-admin shutdown
	touch /var/lib/mysql/.firstmount
fi

#run the server again but now in foreground.
exec mariadbd-safe
