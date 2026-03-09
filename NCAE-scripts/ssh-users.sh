#!/bin/bash
# SSH users correction script
# Checks list of SSH users. If they don't exist, create them. Then vrify home directories and add SSH key

# set variables
# List of SSH users to verify
SSH_USERS=(
    "camille_jenatzy"
    "gaston_chasseloup"
    "leon_serpollet"
    "william_vanderbilt"
    "henri_fournier"
    "maurice_augieres"
    "arthur_duray"
    "henry_ford"
    "louis_rigolly"
    "pierre_caters"
    "paul_baras"
    "victor_hemery"
    "fred_marriott"
    "lydston_hornsted"
    "kenelm_guinness"
    "rene_thomas"
    "ernest_eldridge"
    "malcolm_campbell"
    "ray_keech"
    "john_cobb"
    "dorothy_levitt"
    "paula_murphy"
    "betty_skelton"
    "rachel_kushner"
    "kitty_oneil"
    "jessi_combs"
    "andy_green"
)
SSH_PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcM4aDj8Y4COv+f8bd2WsrIynlbRGgDj2+q9aBeW1Umj5euxnO1vWsjfkpKnyE/ORsI6gkkME9ojAzNAPquWMh2YG+n11FB1iZl2S6yuZB7dkVQZSKpVYwRvZv2RnYDQdcVnX9oWMiGrBWEAi4jxcYykz8nunaO2SxjEwzuKdW8lnnh2BvOO9RkzmSXIIdPYgSf8bFFC7XFMfRrlMXlsxbG3u/NaFjirfvcXKexz06L6qYUzob8IBPsKGaRjO+vEdg6B4lH1lMk1JQ4GtGOJH6zePfB6Gf7rp31261VRfkpbpaDAznTzh7bgpq78E7SenatNbezLDaGq3Zra3j53u7XaSVipkW0S3YcXczhte2J9kvo6u6s094vrcQfB9YigH4KhXpCErFk08NkYAEJDdqFqXIjvzsro+2/EW1KKB9aNPSSM9EZzhYc+cBAl4+ohmEPej1m15vcpw3k+kpo1NC2rwEXIFxmvTme1A2oIZZBpgzUqfmvSPwLXF0EyfN9Lk= SCORING KEY DO NOT REMOVE"

# Create SSH users if they don't exist
for user in "${SSH_USERS[@]}"; do

    if id "$user" &>/dev/null; then
        echo "$user already exists"
    else
        useradd -m "$user"
        echo "$user user created"
    fi

    # Make sure the user's home directory exists with correct permissions
    mkdir -p /home/"$user"/.ssh
    chown -R "$user":"$user" /home/"$user"/.ssh
    chmod 700 /home/"$user"/.ssh

    # Add the shared SSH key to the authorized keys file
    echo "$SSH_PUB_KEY" > /home/"$user"/.ssh/authorized_keys
    chown "$user":"$user" /home/"$user"/.ssh/authorized_keys
    chmod 600 /home/"$user"/.ssh/authorized_keys
    echo "$user user configured with SSH key access"

done

# Check existing regular users in /etc/passwd
echo "Checking for existing users in /etc/passwd with UID >= 1000..."
while IFS=: read -r username _ uid _; do
    # Check for users with UID >= 1000 and compare them to SSH_USERS
    if [[ $uid -ge 1000 ]]; then
        if ! [[ " ${SSH_USERS[@]} " =~ " ${username} " ]]; then
            echo "Suspicious user found: $username"
        fi
    fi
done < /etc/passwd