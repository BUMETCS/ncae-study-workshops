#!/bin/bash
# Setup samba users

SMB_USERS=(
    "benjamin_franklin"
    "alexander_hamilton"
    "john_adams"
    "theodore_roosevelt"
    "franklin_d"
    "winston_churchill"
    "florence_nightingale"
    "eleanor_roosevelt"
    "mother_teresa"
    "mahatma_gandhi"
    "socrates"
    "plato"
    "aristotle"
    "hippocrates"
    "archimedes"
    "rene_descartes"
    "voltaire"
    "jean_jacques_rousseau"
    "immanuel_kant"
    "friedrich_nietzsche"
    "sigmund_freud"
    "charles_darwin"
    "marie_antoinette"
    "louis_xiv"
    "peter_the_great"
)

SMB_HASH='$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1'


# Create local users if they don't exist and set password hash
for user in "${SMB_USERS[@]}"; do

    if id "$user" &>/dev/null; then
        echo "$user already exists"
    else
        useradd -m "$user"
        usermod -p "$SMB_HASH" "$user"
        echo "$user user created"
    fi

done

