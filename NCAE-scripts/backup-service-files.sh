#!/bin/bash
# Create a tar ball of service config files.
# Replace service names with your own service files to customize
# Note: The backups directory must already exist

BACKUP_DIRECTORY="/backups"
TAR_NAME="apache_service_backup.tar.gz"
BACKED_UP_FILES=(
	"/etc/httpd/conf"
	"/etc/httpd/conf.d"
	"/var/www/html"
	"/usr/lib/systemd/system/httpd.service"
	"/usr/sbin/httpd"
)

# Create a tarball
echo "Creating tarball"
tar -czf "$BACKUP_DIRECTORY/$TAR_NAME" "${BACKED_UP_FILES[@]}"

echo "Backup complete!"
