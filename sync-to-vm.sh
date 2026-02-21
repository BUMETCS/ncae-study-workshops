#!/bin/bash
# Sync the workshop to the Vultr VM
# Usage: ./sync-to-vm.sh [ip]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VULTR_DIR="$(dirname "$SCRIPT_DIR")/vultr"

# Get IP from argument, or from manage.sh
if [ -n "$1" ]; then
    IP="$1"
elif [ -f "$VULTR_DIR/.instance_ip" ]; then
    IP=$(cat "$VULTR_DIR/.instance_ip")
else
    echo "Usage: $0 <vm-ip>"
    echo "  or deploy the VM first (../vultr/deploy.sh)"
    exit 1
fi

echo "Syncing workshop to $IP..."
scp -o StrictHostKeyChecking=no -r "$SCRIPT_DIR" root@"$IP":/root/workshop
echo ""
echo "Done! SSH in and run:"
echo "  ssh root@$IP"
echo "  ./workshop/workshop.sh"
