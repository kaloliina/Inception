#!/bin/bash
set -e
echo "memory_limit = 512M" >> /etc/php82/php.ini
cd /var/www/html

if [ ! -e /etc/.firstrun ]; then
	sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf
	touch /etc/.firstrun
fi

#On the first volume mount, download and configure wordpress
#isnt this kinda done in docker compose, we dont compose wordpress until mariadb rdy..
if [ ! -e .firstmount ]; then
	mariadb-admin ping --protocol=tcp --host=mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null

if [ ! -f wp-config.php ]; then
	echo "Installing Wordpress......"

	wp core download --allow-root
	wp config create --allow-root \
		--dbhost=mariadb \
		--dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" \ 
		--dbname="$MYSQL_DATABASE"

	wp core install --allow-root \
		--skip-email \
		--url="$DOMAIN_NAME" \
		--title="$WORDPRESS_TITLE" \
		--admin_user="$WORDPRESS_ADMIN_USER" \
		--admin_password="$WORDPRESS_ADMIN_PASSWORD" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL" \
		--path=/var/www/html

	#create regular user if it doesnt exist
	if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
		wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --all
	fi

else
	echo "WordPress is already installed."
fi
chmod o+w -R /var/www/html/wp-content
touch .firstmount
fi
exec /usr/sbin/php-fpm82 -F

#Checks if wp is already condigured
#Downloads the latest WP core files. || true ensures that the scirpt continues even if the download fails (wordpress)
#is already downloaded.... but in which scenario this would happen??
#wp config create creates config file with db connections details
#wp core install installs wordpress and sets up the site with the provided parameters
#creates user if not existing
#ensures wp-content dir is writable by all users???
#starts the PHP-FPM service in the foreground. the exec command replaces te current shell process with the
#php-fpm82 process, which is the main process of the containers. This ensures that the PHP FPM service is the primary
#process running and will handle incoming PHP requests.
