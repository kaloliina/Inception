#!/bin/bash
set -e #script exists immediately if any command exits with non-zero status

 #creates an empty file to indicate that the first run config has been done
 #enables networking
#server should listen to all IP addresses
 #specifies that the following lines are config settings for the MariaDB daemon
 #Appends config settings to mariadb to ensure that the mariaDB server binds to all IP addresses 0.0.0.0 and enables networking
if [ ! -e /etc/.firstrun ]; then #if the file firstrun does not exist. If true, then this is first time container is being run
	cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
	touch /etc/.firstrun
fi
 #if firstmount does not exist, indicating the db volume ins being mounted for the first time
 #initializes the db in the specified data directory with right user group settings. Output suppressed
		#starts the Mariadb server in the background using mysqld safe. Stores the process id of the mariadb server started in the background
 #waits for the MariaDB server to start by pinging it. Output suppressed
#uses a heredoc to pipe SQL commands to the Mariadb server
 #this reloads the privilege tables to ensure the change takes effect
if [ ! -e /var/lib/mysql/.firstmount ]; then
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
		--auth-root-authentication-method=socket >/dev/null 2>/dev/null
		mysqld_safe &
		mysqld_pid=$!

		mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
		cat << EOF | mysql --protocol=socket -u root -p= 
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
	mysqladmin shutdown
	touch /var/lib/mysql/.firstmount
fi

exec mysqld_safe
 #shuts down the temporary server
  #creates an empty file to indicate that the volume has been initialized
  #replaces the current shell with the mysqld safe process, effectively running the MariaDB server in safe mode for better error handling
