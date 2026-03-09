#!/bin/bash
# Kyle Vandoremalen - 2025

# Backup network config files
# Set the backup variables
# Edit the TAR_NAME so each server gets its own network backup file (replace 'apache')

BACKUP_DIRECTORY="/backups"
TAR_NAME="apache_network_backup.tar.gz"
BACKED_UP_FILES=()

# Check for common networking files and directories
if [ -d /etc/network/interfaces.d ]; then
    BACKED_UP_FILES+=("/etc/network/interfaces.d/")
fi
if [ -f /etc/network/interfaces ]; then
    BACKED_UP_FILES+=("/etc/network/interfaces")
fi
if [ -d /etc/netplan ]; then
    BACKED_UP_FILES+=("/etc/netplan/")
fi
if [ -d /etc/sysconfig/network-scripts ]; then
    BACKED_UP_FILES+=("/etc/sysconfig/network-scripts/")
fi
if [ -f /etc/hosts ]; then
    BACKED_UP_FILES+=("/etc/hosts")
fi
if [ -f /etc/resolv.conf ]; then
    BACKED_UP_FILES+=("/etc/resolv.conf")
fi
if [ -f /etc/hostname ]; then
    BACKED_UP_FILES+=("/etc/hostname")
fi

# Create the backup tarball
echo "Backing up networking files..."
tar -czf "$BACKUP_DIRECTORY/$TAR_NAME" "${BACKED_UP_FILES[@]}"

echo "Backup complete!"
