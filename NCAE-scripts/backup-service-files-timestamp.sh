#!/bin/bash
# Create a tar ball of service config files.
# Replace service names with your own service files to customize
# Note: The backups directory must already exist

BACKUP_DIRECTORY="/backups"
TAR_NAME="apache_service_backup"
TIMESTAMP=$(date +%H-%M)
BACKED_UP_FILES=(
	"/etc/httpd/conf"
	"/etc/httpd/conf.d"
	"/var/www/html"
	"/usr/lib/systemd/system/httpd.service"
	"/usr/sbin/httpd"
)

# Create a tarball
echo "Creating tarball"

NEW_BACKUP_FILE="$BACKUP_DIRECTORY/${TAR_NAME}_${TIMESTAMP}.tar.gz"
tar -czf "$NEW_BACKUP_FILE" "${BACKED_UP_FILES[@]}"
cp "$NEW_BACKUP_FILE" "$BACKUP_DIRECTORY/${TAR_NAME}_LATEST.tar.gz"


echo "Backup complete!"
