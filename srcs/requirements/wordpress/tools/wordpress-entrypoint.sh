#!/bin/bash
set -e
#This increases the PHP memory limit. We need to increase it because otherwise we ran into memory errors.
echo "memory_limit = 512M" >> /etc/php82/php.ini
cd /var/www/html

#/etc is not on volume so resets on rebuild. sed-i edits the php-fpm config file, replacing 127.0.0.1 with just 9000
#so php-fpm listens on all interfaces, allowing nginx in a separate container to reach it.
if [ ! -e /etc/.firstrun ]; then
	sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf
	touch /etc/.firstrun
fi

#if wordpress config already exists, skip the whole install.
#wp core download, downloads WP core files into var/www/html. Root is needed because the script runs as root.
#wp config creates the config file, which then tells how to connect to the database.
#wp core install actually installs wordpress, connects to mariadb, creates all tables WordPress needs.
#lastly we create a regular author user. This is non-admin user.
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

		wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root

else
	echo "WordPress is already installed."
fi
#make wp content writable by all users. WP needs to write to this directory for uploads, theme, comments etc
chmod o+w -R /var/www/html/wp-content

#Launch PHP-FPM process on the foreground.
exec /usr/sbin/php-fpm82 -F
