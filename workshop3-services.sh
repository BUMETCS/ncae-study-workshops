#!/bin/bash
# ============================================================================
#  NCAE Cybersecurity Competition — Services & Security Workshop
#  Interactive training: Apache, SSH, DNS, Rsync/Cron, UFW, Active Defense
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX="/tmp/services-workshop"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────────────────

clear_screen() {
    clear 2>/dev/null || printf '\033[2J\033[H'
}

banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}          NCAE Services & Security Workshop                 ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}          Apache · SSH · DNS · Cron · UFW · Defense          ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

section_header() {
    local title="$1"
    local width=60
    local pad=$(( (width - ${#title} - 2) / 2 ))
    echo ""
    echo -e "${BLUE}$(printf '─%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}$(printf ' %.0s' $(seq 1 $pad))${BOLD}${title}${NC}"
    echo -e "${BLUE}$(printf '─%.0s' $(seq 1 $width))${NC}"
    echo ""
}

info() {
    echo -e "  ${CYAN}ℹ${NC}  $1"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC}  $1"
}

success() {
    echo -e "  ${GREEN}✔${NC}  $1"
}

fail() {
    echo -e "  ${RED}✘${NC}  $1"
}

explain() {
    echo -e "  ${MAGENTA}▸${NC} $1"
}

show_command() {
    echo -e "  ${DIM}\$${NC} ${GREEN}$1${NC}"
}

run_command() {
    echo ""
    echo -e "  ${DIM}\$${NC} ${GREEN}$1${NC}"
    echo -e "  ${DIM}───────────────────────────────────${NC}"
    eval "$1" 2>&1 | while IFS= read -r line; do
        echo -e "  ${DIM}│${NC} $line"
    done
    echo -e "  ${DIM}└─${NC}"
}

show_file() {
    local label="$1"
    shift
    echo -e "  ${YELLOW}# $label${NC}"
    while IFS= read -r line; do
        echo -e "  ${DIM}│${NC} $line"
    done <<< "$@"
    echo -e "  ${DIM}└─${NC}"
}

pause() {
    echo ""
    echo -ne "  ${DIM}Press Enter to continue...${NC}"
    read -r
}

ask_yn() {
    echo -ne "  ${CYAN}?${NC} $1 [y/n]: "
    read -r answer
    [[ "$answer" =~ ^[Yy] ]]
}

try_it() {
    echo ""
    echo -e "  ${YELLOW}🧪 TRY IT:${NC} ${BOLD}$1${NC}"
    echo -ne "  ${DIM}Press Enter to run, or 's' to skip: ${NC}"
    read -r answer
    if [[ ! "$answer" =~ ^[Ss] ]]; then
        run_command "$1"
    fi
}

sandbox_setup() {
    mkdir -p "$SANDBOX" 2>/dev/null
}

sandbox_cleanup() {
    rm -rf "$SANDBOX" 2>/dev/null
}

# ── Module 1: Web Services with Apache ───────────────────────────────────────

module_apache() {
    clear_screen
    section_header "Module 1: Web Services with Apache"

    echo -e "  ${BOLD}Apache${NC} (a.k.a. ${BOLD}httpd${NC}) is one of the most common web servers."
    echo -e "  In the competition, you'll likely need to get a web server"
    echo -e "  running, serve specific content, and keep it alive."
    echo ""
    echo -e "  ${DIM}Fun fact: Apache serves about 30% of all websites on the internet.${NC}"
    pause

    # ── 1.1 Installing Apache ──
    section_header "1.1 — Installing Apache"

    info "The package name differs between distros:"
    echo ""
    echo -e "    ${BOLD}Debian/Ubuntu/Kali:${NC}  ${GREEN}sudo apt install apache2${NC}"
    echo -e "    ${BOLD}CentOS/RHEL:${NC}         ${GREEN}sudo yum install httpd${NC}"
    echo ""
    warn "The ${BOLD}service name${NC} also differs:"
    echo -e "    Debian/Ubuntu → ${BOLD}apache2${NC}"
    echo -e "    CentOS/RHEL   → ${BOLD}httpd${NC}"
    echo ""
    info "This is one of the most common gotchas in the competition."
    pause

    # ── 1.2 Starting / Managing the Service ──
    section_header "1.2 — Managing the Apache Service"

    info "${BOLD}systemctl${NC} is how you control services in modern Linux."
    info "Think of it as the on/off switch for background programs."
    echo ""

    explain "${BOLD}Start${NC} the service (turns it on right now):"
    show_command "sudo systemctl start apache2"
    echo ""

    explain "${BOLD}Stop${NC} the service:"
    show_command "sudo systemctl stop apache2"
    echo ""

    explain "${BOLD}Restart${NC} (stop + start — use after config changes):"
    show_command "sudo systemctl restart apache2"
    echo ""

    explain "${BOLD}Reload${NC} (re-read config without dropping connections):"
    show_command "sudo systemctl reload apache2"
    echo ""

    explain "${BOLD}Enable${NC} (start automatically on boot — critical!):"
    show_command "sudo systemctl enable apache2"
    echo ""

    explain "${BOLD}Status${NC} (check if it's running):"
    show_command "sudo systemctl status apache2"
    echo ""

    warn "${BOLD}start${NC} = turn on now.  ${BOLD}enable${NC} = turn on at boot."
    warn "You usually want BOTH: ${BOLD}sudo systemctl enable --now apache2${NC}"
    echo ""
    info "The ${BOLD}--now${NC} flag combines enable + start in one command."

    echo ""
    if ask_yn "Check if Apache is installed/running on this system?"; then
        run_command "systemctl status apache2 2>/dev/null || systemctl status httpd 2>/dev/null || echo 'Apache not found — install it with: sudo apt install apache2'"
    fi
    pause

    # ── 1.3 Where Web Files Live ──
    section_header "1.3 — The Document Root"

    info "Apache serves files from a directory called the ${BOLD}document root${NC}."
    echo ""
    echo -e "    ${BOLD}Debian/Ubuntu:${NC}  ${GREEN}/var/www/html/${NC}"
    echo -e "    ${BOLD}CentOS/RHEL:${NC}    ${GREEN}/var/www/html/${NC}  (same!)"
    echo ""
    info "Whatever you put in this folder shows up on the website."
    echo ""
    explain "Create a simple web page:"
    show_command "echo '<h1>Hello from our server!</h1>' | sudo tee /var/www/html/index.html"
    echo ""
    info "Now browsing to ${BOLD}http://your-server-ip${NC} shows that page."
    echo ""
    explain "Test it from the command line with ${BOLD}curl${NC}:"
    show_command "curl http://localhost"
    echo -e "    ${DIM}curl fetches a web page from the terminal — no browser needed${NC}"

    echo ""
    if ask_yn "Try curling localhost? (only works if Apache is running)"; then
        run_command "curl -s http://localhost 2>/dev/null | head -5 || echo 'Apache not running on this machine'"
    fi
    pause

    # ── 1.4 Config Files ──
    section_header "1.4 — Apache Configuration"

    info "Apache config lives in different places per distro:"
    echo ""
    echo -e "  ${BOLD}Debian/Ubuntu:${NC}"
    echo -e "    ${GREEN}/etc/apache2/apache2.conf${NC}        ${DIM}← main config${NC}"
    echo -e "    ${GREEN}/etc/apache2/sites-available/${NC}    ${DIM}← virtual host configs${NC}"
    echo -e "    ${GREEN}/etc/apache2/sites-enabled/${NC}      ${DIM}← active sites (symlinks)${NC}"
    echo -e "    ${GREEN}/etc/apache2/ports.conf${NC}          ${DIM}← which ports to listen on${NC}"
    echo ""
    echo -e "  ${BOLD}CentOS/RHEL:${NC}"
    echo -e "    ${GREEN}/etc/httpd/conf/httpd.conf${NC}       ${DIM}← main config (everything in one file)${NC}"
    echo -e "    ${GREEN}/etc/httpd/conf.d/${NC}               ${DIM}← additional configs${NC}"
    echo ""

    info "Listening port (default: 80):"
    echo ""
    show_file "/etc/apache2/ports.conf" \
"Listen 80

<IfModule ssl_module>
    Listen 443
</IfModule>"
    echo ""
    info "To change the port, edit this file and restart Apache."
    pause

    # ── 1.5 Virtual Hosts ──
    section_header "1.5 — Virtual Hosts"

    info "Virtual hosts let one Apache server host multiple websites."
    info "Each site gets its own config file."
    echo ""

    show_file "/etc/apache2/sites-available/mysite.conf" \
"<VirtualHost *:80>
    ServerName mysite.example.com
    DocumentRoot /var/www/mysite

    ErrorLog \${APACHE_LOG_DIR}/mysite-error.log
    CustomLog \${APACHE_LOG_DIR}/mysite-access.log combined
</VirtualHost>"
    echo ""

    info "Enable the site:"
    show_command "sudo a2ensite mysite.conf"
    echo ""
    info "Disable a site:"
    show_command "sudo a2dissite mysite.conf"
    echo ""
    info "After any config change:"
    show_command "sudo systemctl reload apache2"
    echo ""
    info "Test config syntax before reloading (catches errors):"
    show_command "sudo apache2ctl configtest"
    echo -e "    ${DIM}Should say \"Syntax OK\"${NC}"
    pause

    # ── 1.6 Logs ──
    section_header "1.6 — Apache Logs"

    info "Logs are your best friend for debugging and forensics."
    echo ""
    echo -e "    ${GREEN}/var/log/apache2/access.log${NC}  ${DIM}← who visited, when, what${NC}"
    echo -e "    ${GREEN}/var/log/apache2/error.log${NC}   ${DIM}← what went wrong${NC}"
    echo ""
    info "Watch the access log live while people visit:"
    show_command "sudo tail -f /var/log/apache2/access.log"
    echo ""
    info "Search for suspicious activity:"
    show_command "grep '404' /var/log/apache2/access.log | tail -20"
    show_command "grep -i 'sql\\|union\\|select\\|script' /var/log/apache2/access.log"
    pause

    # ── Exercise ──
    section_header "Exercise: Stand Up a Web Server"

    echo -e "  ${BOLD}Scenario:${NC} You need a web server running ASAP for scoring."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Install Apache"
    echo "    2. Start it AND enable it at boot (one command)"
    echo "    3. Create an index.html with your team name"
    echo "    4. Verify it's working with curl"
    echo "    5. Check which port it's listening on"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "sudo apt install -y apache2"
        show_command "sudo systemctl enable --now apache2"
        show_command "echo '<h1>Team Alpha</h1>' | sudo tee /var/www/html/index.html"
        show_command "curl http://localhost"
        show_command "sudo ss -tlnp | grep apache"
        echo ""
        success "The ${BOLD}ss${NC} command shows listening ports — we'll cover it in Module 6."
    fi
    pause
}

# ── Module 2: SSH Service ────────────────────────────────────────────────────

module_ssh() {
    clear_screen
    section_header "Module 2: SSH (Secure Shell)"
    sandbox_setup

    echo -e "  ${BOLD}SSH${NC} is how you remotely log into another machine's terminal."
    echo -e "  It encrypts everything — your password, your commands,"
    echo -e "  the output. It replaces old insecure tools like telnet."
    echo ""
    echo -e "  You will use SSH ${BOLD}constantly${NC} in the competition to manage"
    echo -e "  machines from one central workstation."
    pause

    # ── 2.1 Basics ──
    section_header "2.1 — SSH Basics"

    info "Connecting to a remote machine:"
    echo ""
    show_command "ssh username@ip-address"
    echo -e "    ${DIM}Example: ssh bob@10.0.0.5${NC}"
    echo ""

    info "First time connecting? You'll see this:"
    echo -e "    ${DIM}The authenticity of host '10.0.0.5' can't be established.${NC}"
    echo -e "    ${DIM}ECDSA key fingerprint is SHA256:abc123...${NC}"
    echo -e "    ${DIM}Are you sure you want to continue connecting (yes/no)?${NC}"
    echo ""
    explain "Type ${BOLD}yes${NC}. This saves the server's fingerprint so you"
    explain "know you're talking to the same machine next time."
    echo ""

    info "Connect on a different port (default is 22):"
    show_command "ssh -p 2222 bob@10.0.0.5"
    echo ""

    info "Run a single command remotely without opening a shell:"
    show_command "ssh bob@10.0.0.5 'uptime'"
    echo -e "    ${DIM}Runs 'uptime' on the remote machine, prints output, disconnects${NC}"
    pause

    # ── 2.2 Installing & Managing the SSH Server ──
    section_header "2.2 — The SSH Server (sshd)"

    info "The SSH ${BOLD}client${NC} (what you type ${BOLD}ssh${NC} with) is usually pre-installed."
    info "The SSH ${BOLD}server${NC} (what lets others connect TO you) might not be."
    echo ""
    show_command "sudo apt install openssh-server"
    echo ""
    show_command "sudo systemctl enable --now sshd"
    echo ""
    info "Verify it's running:"
    show_command "sudo systemctl status sshd"
    echo ""

    echo ""
    if ask_yn "Check if SSH server is running on this system?"; then
        run_command "systemctl status sshd 2>/dev/null || systemctl status ssh 2>/dev/null || echo 'SSH server not running'"
    fi
    pause

    # ── 2.3 SSH Config File ──
    section_header "2.3 — SSH Server Configuration"

    info "The SSH server config file:"
    echo -e "    ${GREEN}/etc/ssh/sshd_config${NC}"
    echo ""
    warn "There are TWO config files — don't mix them up:"
    echo -e "    ${GREEN}/etc/ssh/sshd_config${NC}   ${DIM}← server config (the 'd' = daemon)${NC}"
    echo -e "    ${GREEN}/etc/ssh/ssh_config${NC}    ${DIM}← client config (how YOUR ssh behaves)${NC}"
    echo ""

    info "Key settings in ${BOLD}sshd_config${NC}:"
    echo ""
    show_file "Important sshd_config settings" \
"Port 22                          # Which port to listen on
PermitRootLogin no               # NEVER allow direct root login
PasswordAuthentication yes       # Allow password login (disable later)
PubkeyAuthentication yes         # Allow SSH key login
MaxAuthTries 3                   # Lock out after 3 failed attempts
AllowUsers bob alice             # Only these users can SSH in"
    echo ""
    warn "After editing sshd_config, ALWAYS restart the service:"
    show_command "sudo systemctl restart sshd"
    echo ""
    warn "Test your config BEFORE disconnecting your current session!"
    warn "If you broke something, you'd lock yourself out."
    info "Open a ${BOLD}second${NC} SSH session to test, keep the first one open."
    pause

    # ── 2.4 SSH Keys ──
    section_header "2.4 — SSH Keys (Cryptographic Authentication)"

    info "Passwords can be guessed or brute-forced."
    info "SSH keys are ${BOLD}much${NC} more secure — they use cryptography."
    echo ""
    echo -e "  ${BOLD}How it works:${NC}"
    echo -e "    1. You generate a ${BOLD}key pair${NC}: a private key + a public key"
    echo -e "    2. The ${BOLD}private key${NC} stays on YOUR machine (${RED}never share it!${NC})"
    echo -e "    3. The ${BOLD}public key${NC} goes on the server you want to access"
    echo -e "    4. When you connect, the keys do a crypto handshake"
    echo ""
    echo -e "  Think of it like a lock and key:"
    echo -e "    ${BOLD}Public key${NC}  = the lock (you can give copies to everyone)"
    echo -e "    ${BOLD}Private key${NC} = the key (only YOU have it)"
    pause

    # ── 2.5 Generating Keys ──
    section_header "2.5 — Generating SSH Keys"

    info "Generate a key pair with ${BOLD}ssh-keygen${NC}:"
    echo ""
    show_command "ssh-keygen -t ed25519 -C 'bob@competition'"
    echo ""
    echo -e "  ${DIM}Generating public/private ed25519 key pair.${NC}"
    echo -e "  ${DIM}Enter file in which to save the key (/home/bob/.ssh/id_ed25519):${NC}"
    echo -e "  ${DIM}Enter passphrase (empty for no passphrase):${NC}"
    echo ""
    info "It creates two files:"
    echo -e "    ${GREEN}~/.ssh/id_ed25519${NC}       ${DIM}← PRIVATE key (permissions must be 600)${NC}"
    echo -e "    ${GREEN}~/.ssh/id_ed25519.pub${NC}   ${DIM}← PUBLIC key (this goes on servers)${NC}"
    echo ""

    info "Key types (strongest to weakest):"
    echo -e "    ${GREEN}ed25519${NC}   ${DIM}← recommended (fast, small, modern)${NC}"
    echo -e "    ${GREEN}ecdsa${NC}     ${DIM}← good alternative${NC}"
    echo -e "    ${GREEN}rsa${NC}       ${DIM}← older, use 4096 bits minimum: ${NC}${GREEN}ssh-keygen -t rsa -b 4096${NC}"
    echo ""
    warn "If your private key permissions are too open, SSH refuses to use it:"
    show_command "chmod 600 ~/.ssh/id_ed25519"

    echo ""
    if ask_yn "Check if you already have SSH keys?"; then
        run_command "ls -la ~/.ssh/ 2>/dev/null || echo 'No .ssh directory found — you have no keys yet'"
    fi
    pause

    # ── 2.6 Passwordless Auth ──
    section_header "2.6 — Passwordless Authentication"

    info "Once you have keys, copy the public key to a remote server:"
    echo ""
    explain "${BOLD}Easy way${NC} — ssh-copy-id does everything for you:"
    show_command "ssh-copy-id bob@10.0.0.5"
    echo -e "    ${DIM}Prompts for bob's password ONE time, then copies the key${NC}"
    echo ""

    explain "${BOLD}Manual way${NC} — if ssh-copy-id isn't available:"
    show_command "cat ~/.ssh/id_ed25519.pub | ssh bob@10.0.0.5 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
    echo ""

    info "What this does on the remote server:"
    echo -e "    ${DIM}Appends your public key to ${NC}${GREEN}~/.ssh/authorized_keys${NC}"
    echo ""

    info "Now you can log in without a password:"
    show_command "ssh bob@10.0.0.5"
    echo -e "    ${DIM}(no password prompt — the key handles authentication)${NC}"
    echo ""

    warn "Permissions matter! The remote server's .ssh must be locked down:"
    show_command "chmod 700 ~/.ssh"
    show_command "chmod 600 ~/.ssh/authorized_keys"
    echo -e "    ${DIM}If permissions are wrong, SSH silently falls back to password auth${NC}"
    pause

    # ── 2.7 Hardening ──
    section_header "2.7 — SSH Hardening (Competition Must-Do)"

    info "Once key auth works, lock down the server:"
    echo ""
    show_file "Edit /etc/ssh/sshd_config" \
"# Disable password auth (keys only)
PasswordAuthentication no

# Disable root login entirely
PermitRootLogin no

# Only allow specific users
AllowUsers bob alice

# Change the default port (obscurity, not security, but helps)
Port 2222

# Limit authentication attempts
MaxAuthTries 3

# Disable empty passwords
PermitEmptyPasswords no"
    echo ""
    show_command "sudo systemctl restart sshd"
    echo ""
    warn "Remember: test with a SECOND session before closing the first!"
    pause

    # ── 2.8 SCP & SFTP ──
    section_header "2.8 — Copying Files Over SSH"

    info "SSH isn't just for remote shells — you can copy files too."
    echo ""
    explain "${BOLD}scp${NC} — secure copy (like cp but over the network):"
    echo ""
    show_command "scp localfile.txt bob@10.0.0.5:/home/bob/"
    echo -e "    ${DIM}Copy local file → remote machine${NC}"
    echo ""
    show_command "scp bob@10.0.0.5:/var/log/syslog ./syslog-backup"
    echo -e "    ${DIM}Copy remote file → local machine${NC}"
    echo ""
    show_command "scp -r ./mydir bob@10.0.0.5:/home/bob/"
    echo -e "    ${DIM}-r = recursive (copy a whole directory)${NC}"
    echo ""

    explain "${BOLD}sftp${NC} — interactive file browser over SSH:"
    show_command "sftp bob@10.0.0.5"
    echo -e "    ${DIM}Opens an FTP-like shell: ls, cd, get, put, quit${NC}"
    pause

    # ── Exercise ──
    section_header "Exercise: SSH Setup Drill"

    echo -e "  ${BOLD}Scenario:${NC} Set up secure SSH access to a new server."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Generate an ed25519 key pair"
    echo "    2. Copy the public key to the remote server"
    echo "    3. Test passwordless login"
    echo "    4. Disable password auth and root login in sshd_config"
    echo "    5. Restart SSH and verify from a second session"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "ssh-keygen -t ed25519 -C 'mykey'"
        show_command "ssh-copy-id user@remote-server"
        show_command "ssh user@remote-server"
        echo ""
        info "Edit ${BOLD}/etc/ssh/sshd_config${NC} on the remote server:"
        show_command "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
        show_command "sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
        show_command "sudo systemctl restart sshd"
    fi
    pause
}

# ── Module 3: DNS Service ────────────────────────────────────────────────────

module_dns() {
    clear_screen
    section_header "Module 3: DNS (Domain Name System)"
    sandbox_setup

    echo -e "  ${BOLD}DNS${NC} translates human-readable names (google.com) into"
    echo -e "  IP addresses (142.250.80.46). Without DNS, you'd have to"
    echo -e "  memorize IP addresses for every website."
    echo ""
    echo -e "  In the competition, you'll run your own DNS server using"
    echo -e "  ${BOLD}BIND${NC} (Berkeley Internet Name Domain) — the most common"
    echo -e "  DNS server software on the planet."
    pause

    # ── 3.1 DNS Concepts ──
    section_header "3.1 — DNS Concepts"

    info "Key terms you need to know:"
    echo ""
    echo -e "  ${BOLD}A Record${NC}       hostname → IPv4 address"
    echo -e "                   ${DIM}webserver.team.local  →  10.0.0.50${NC}"
    echo ""
    echo -e "  ${BOLD}AAAA Record${NC}    hostname → IPv6 address"
    echo ""
    echo -e "  ${BOLD}PTR Record${NC}     IP address → hostname (reverse lookup)"
    echo -e "                   ${DIM}10.0.0.50  →  webserver.team.local${NC}"
    echo ""
    echo -e "  ${BOLD}CNAME Record${NC}   alias → real hostname"
    echo -e "                   ${DIM}www.team.local  →  webserver.team.local${NC}"
    echo ""
    echo -e "  ${BOLD}MX Record${NC}      domain → mail server"
    echo -e "                   ${DIM}team.local  →  mail.team.local${NC}"
    echo ""
    echo -e "  ${BOLD}NS Record${NC}      domain → name server (who runs DNS for this domain)"
    echo ""
    echo -e "  ${BOLD}SOA Record${NC}     \"Start of Authority\" — metadata about the zone"
    echo ""
    echo -e "  ${BOLD}Zone${NC}           a domain + all its records"
    echo -e "  ${BOLD}Forward Zone${NC}   name → IP lookups"
    echo -e "  ${BOLD}Reverse Zone${NC}   IP → name lookups"
    pause

    # ── 3.2 Installing BIND ──
    section_header "3.2 — Installing BIND"

    info "Install BIND:"
    echo ""
    echo -e "    ${BOLD}Debian/Ubuntu:${NC}  ${GREEN}sudo apt install bind9 bind9utils${NC}"
    echo -e "    ${BOLD}CentOS/RHEL:${NC}    ${GREEN}sudo yum install bind bind-utils${NC}"
    echo ""
    show_command "sudo systemctl enable --now named"
    echo -e "    ${DIM}On some systems the service is called 'bind9' instead of 'named'${NC}"
    echo ""

    info "Config files:"
    echo -e "    ${GREEN}/etc/bind/named.conf${NC}                 ${DIM}← main config${NC}"
    echo -e "    ${GREEN}/etc/bind/named.conf.options${NC}         ${DIM}← server options${NC}"
    echo -e "    ${GREEN}/etc/bind/named.conf.local${NC}           ${DIM}← your zone definitions${NC}"
    echo -e "    ${GREEN}/var/cache/bind/${NC} or ${GREEN}/var/named/${NC}    ${DIM}← zone data files${NC}"
    pause

    # ── 3.3 Configuring Options ──
    section_header "3.3 — Server Options"

    info "Configure ${BOLD}/etc/bind/named.conf.options${NC}:"
    echo ""
    show_file "/etc/bind/named.conf.options" \
"options {
    directory \"/var/cache/bind\";

    // Allow queries from your network
    allow-query { any; };

    // Forward unknown queries to an upstream DNS
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    // Enable recursive queries for local clients
    recursion yes;
    allow-recursion { 10.0.0.0/24; localhost; };

    listen-on { any; };

    dnssec-validation auto;
};"
    echo ""
    explain "${BOLD}forwarders${NC} — if your server doesn't know an answer, ask Google"
    explain "${BOLD}allow-query${NC} — who can send DNS queries to you"
    explain "${BOLD}recursion${NC} — let your server look up domains it doesn't host"
    pause

    # ── 3.4 Forward Zone ──
    section_header "3.4 — Creating a Forward Zone"

    info "A forward zone maps names → IPs. Two steps:"
    echo ""
    info "Step 1: Declare the zone in ${BOLD}named.conf.local${NC}:"
    echo ""
    show_file "/etc/bind/named.conf.local" \
"zone \"team.local\" {
    type master;
    file \"/etc/bind/zones/db.team.local\";
};"
    echo ""

    info "Step 2: Create the zone data file:"
    echo ""
    show_file "/etc/bind/zones/db.team.local" \
"\$TTL    604800
@       IN      SOA     ns1.team.local. admin.team.local. (
                        2025011501  ; Serial (increment on changes!)
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL

; Name servers
@       IN      NS      ns1.team.local.

; A records (name → IP)
ns1             IN      A       10.0.0.1
webserver       IN      A       10.0.0.50
mailserver      IN      A       10.0.0.60
fileserver      IN      A       10.0.0.70

; Aliases
www             IN      CNAME   webserver.team.local.
mail            IN      CNAME   mailserver.team.local."
    echo ""
    warn "Notice the trailing dots (.) after full domain names — they're required!"
    warn "Without them, BIND appends the zone name again (team.local.team.local)."
    echo ""
    warn "The ${BOLD}serial number${NC} must be incremented every time you edit the zone."
    info "Convention: ${BOLD}YYYYMMDDNN${NC} (date + change number)"
    pause

    # ── 3.5 Reverse Zone ──
    section_header "3.5 — Creating a Reverse Zone"

    info "A reverse zone maps IPs → names (PTR records)."
    echo ""
    info "Step 1: Declare in ${BOLD}named.conf.local${NC}:"
    echo ""
    show_file "/etc/bind/named.conf.local (add this)" \
"zone \"0.0.10.in-addr.arpa\" {
    type master;
    file \"/etc/bind/zones/db.10.0.0\";
};"
    echo ""
    explain "The zone name is the network address ${BOLD}reversed${NC} + .in-addr.arpa"
    explain "10.0.0.x → ${BOLD}0.0.10${NC}.in-addr.arpa"
    echo ""

    info "Step 2: Create the zone data file:"
    echo ""
    show_file "/etc/bind/zones/db.10.0.0" \
"\$TTL    604800
@       IN      SOA     ns1.team.local. admin.team.local. (
                        2025011501  ; Serial
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL

; Name server
@       IN      NS      ns1.team.local.

; PTR records (IP → name)
1       IN      PTR     ns1.team.local.
50      IN      PTR     webserver.team.local.
60      IN      PTR     mailserver.team.local.
70      IN      PTR     fileserver.team.local."
    echo ""
    explain "The numbers (1, 50, 60...) are the last octet of the IP."
    explain "Combined with the zone name: 1.0.0.10.in-addr.arpa → ns1.team.local"
    pause

    # ── 3.6 Testing DNS ──
    section_header "3.6 — Validating & Testing DNS"

    info "Check zone file syntax before restarting:"
    show_command "sudo named-checkzone team.local /etc/bind/zones/db.team.local"
    echo -e "    ${DIM}Should say \"OK\"${NC}"
    echo ""
    show_command "sudo named-checkconf"
    echo -e "    ${DIM}Checks all config files — no output = no errors${NC}"
    echo ""

    info "Restart BIND:"
    show_command "sudo systemctl restart named"
    echo ""

    info "Test with ${BOLD}dig${NC} (the best DNS debugging tool):"
    echo ""
    show_command "dig @10.0.0.1 webserver.team.local"
    echo -e "    ${DIM}Ask the server at 10.0.0.1 to resolve webserver.team.local${NC}"
    echo ""
    show_command "dig @10.0.0.1 -x 10.0.0.50"
    echo -e "    ${DIM}-x = reverse lookup (IP → name)${NC}"
    echo ""

    info "Simpler output with ${BOLD}nslookup${NC}:"
    show_command "nslookup webserver.team.local 10.0.0.1"
    echo ""

    info "Set your machine to use your own DNS server:"
    show_command "echo 'nameserver 10.0.0.1' | sudo tee /etc/resolv.conf"
    warn "${BOLD}/etc/resolv.conf${NC} might get overwritten by DHCP or NetworkManager."

    echo ""
    if ask_yn "Test DNS resolution on this machine?"; then
        run_command "dig google.com +short 2>/dev/null || nslookup google.com 2>/dev/null || echo 'dig/nslookup not installed'"
    fi
    pause

    # ── Exercise ──
    section_header "Exercise: Build a DNS Server"

    echo -e "  ${BOLD}Scenario:${NC} Your team needs DNS for the domain ${BOLD}cyber.local${NC}."
    echo ""
    echo -e "  ${CYAN}Records needed:${NC}"
    echo "    ns1.cyber.local      → 10.0.0.1"
    echo "    web.cyber.local      → 10.0.0.10"
    echo "    db.cyber.local       → 10.0.0.20"
    echo "    www.cyber.local      → CNAME to web.cyber.local"
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Write the named.conf.local zone declaration"
    echo "    2. Write the forward zone file"
    echo "    3. What commands validate and apply the config?"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_file "named.conf.local" \
"zone \"cyber.local\" {
    type master;
    file \"/etc/bind/zones/db.cyber.local\";
};"
        echo ""
        show_file "db.cyber.local" \
"\$TTL 604800
@ IN SOA ns1.cyber.local. admin.cyber.local. (
        2025011501 ; Serial
        604800 ; Refresh
        86400  ; Retry
        2419200 ; Expire
        604800 ) ; Negative TTL

@       IN  NS    ns1.cyber.local.
ns1     IN  A     10.0.0.1
web     IN  A     10.0.0.10
db      IN  A     10.0.0.20
www     IN  CNAME web.cyber.local."
        echo ""
        show_command "sudo named-checkzone cyber.local /etc/bind/zones/db.cyber.local"
        show_command "sudo named-checkconf"
        show_command "sudo systemctl restart named"
        show_command "dig @10.0.0.1 web.cyber.local"
    fi
    pause
}

# ── Module 4: Rsync & Cron ──────────────────────────────────────────────────

module_rsync_cron() {
    clear_screen
    section_header "Module 4: Rsync & Cron (Automated Backups)"
    sandbox_setup

    echo -e "  ${BOLD}rsync${NC} copies files efficiently (only transfers changes)."
    echo -e "  ${BOLD}cron${NC} runs commands on a schedule (every minute, hour, day...)."
    echo -e "  Together, they give you ${BOLD}automatic backups${NC} — a lifesaver"
    echo -e "  in competition when red team is breaking your stuff."
    pause

    # ── 4.1 Rsync Basics ──
    section_header "4.1 — Rsync Basics"

    info "${BOLD}rsync${NC} is like cp but smarter:"
    echo -e "    • Only copies files that have ${BOLD}changed${NC} (incremental)"
    echo -e "    • Can copy ${BOLD}over the network${NC} via SSH"
    echo -e "    • Preserves permissions, timestamps, ownership"
    echo -e "    • Shows progress and handles interruptions"
    echo ""

    explain "Install if not already present:"
    show_command "sudo apt install rsync"
    echo ""

    explain "Basic local sync (like cp -r but better):"
    show_command "rsync -av /var/www/html/ /backup/www/"
    echo ""
    echo -e "    ${BOLD}-a${NC} = archive mode (preserves permissions, timestamps, etc.)"
    echo -e "    ${BOLD}-v${NC} = verbose (show what's being copied)"
    echo ""

    warn "Trailing slash matters!"
    echo -e "    ${GREEN}rsync -av /var/www/html/ /backup/www/${NC}"
    echo -e "    ${DIM}    Copies the CONTENTS of html/ into www/${NC}"
    echo ""
    echo -e "    ${GREEN}rsync -av /var/www/html /backup/www/${NC}"
    echo -e "    ${DIM}    Copies the html/ FOLDER ITSELF into www/ (creates www/html/)${NC}"
    pause

    explain "More useful flags:"
    echo ""
    echo -e "    ${GREEN}-z${NC}          compress during transfer (faster over network)"
    echo -e "    ${GREEN}--delete${NC}    delete files in dest that don't exist in source"
    echo -e "    ${GREEN}--dry-run${NC}   show what WOULD happen without actually doing it"
    echo -e "    ${GREEN}--progress${NC}  show transfer progress"
    echo -e "    ${GREEN}--exclude${NC}   skip certain files/patterns"
    echo ""

    explain "Preview before running (always a good idea):"
    show_command "rsync -av --dry-run /var/www/ /backup/www/"
    pause

    # ── 4.2 Rsync Over SSH ──
    section_header "4.2 — Rsync Over SSH (Remote Backups)"

    info "Rsync can copy files to/from remote machines over SSH:"
    echo ""
    explain "Push local files → remote server:"
    show_command "rsync -avz /var/www/html/ bob@10.0.0.5:/backup/www/"
    echo ""
    explain "Pull remote files → local machine:"
    show_command "rsync -avz bob@10.0.0.5:/var/log/ /backup/remote-logs/"
    echo ""
    explain "Use a non-standard SSH port:"
    show_command "rsync -avz -e 'ssh -p 2222' /var/www/ bob@10.0.0.5:/backup/"
    echo ""
    info "If you set up SSH key auth (Module 2), rsync won't prompt for"
    info "a password — which is essential for automation with cron."
    pause

    # ── 4.3 Let's try it ──
    section_header "4.3 — Hands-On: Local Rsync"

    explain "Create some files to back up:"
    run_command "mkdir -p /tmp/services-workshop/{source,backup} && echo 'important data' > /tmp/services-workshop/source/file1.txt && echo 'critical config' > /tmp/services-workshop/source/file2.txt && ls /tmp/services-workshop/source/"

    try_it "rsync -av /tmp/services-workshop/source/ /tmp/services-workshop/backup/"

    explain "Now modify a file and rsync again — watch that only the changed file transfers:"
    run_command "echo 'updated data' >> /tmp/services-workshop/source/file1.txt"
    try_it "rsync -av /tmp/services-workshop/source/ /tmp/services-workshop/backup/"

    echo ""
    success "See? Only file1.txt was transferred the second time."
    pause

    # ── 4.4 Cron Basics ──
    section_header "4.4 — Cron: Scheduling Commands"

    info "${BOLD}cron${NC} runs commands automatically at specified times."
    info "It's like setting an alarm clock for commands."
    echo ""

    info "Edit your cron schedule:"
    show_command "crontab -e"
    echo ""
    info "View your current cron jobs:"
    show_command "crontab -l"
    echo ""

    info "The cron time format (five fields):"
    echo ""
    echo -e "  ${BOLD}*     *     *     *     *     command${NC}"
    echo -e "  ${DIM}│     │     │     │     │${NC}"
    echo -e "  ${DIM}│     │     │     │     └─ day of week  (0-7, 0 & 7 = Sunday)${NC}"
    echo -e "  ${DIM}│     │     │     └─ month        (1-12)${NC}"
    echo -e "  ${DIM}│     │     └─ day of month  (1-31)${NC}"
    echo -e "  ${DIM}│     └─ hour         (0-23)${NC}"
    echo -e "  ${DIM}└─ minute       (0-59)${NC}"
    echo ""

    info "Examples:"
    echo ""
    echo -e "    ${GREEN}* * * * *${NC}           ${DIM}every minute${NC}"
    echo -e "    ${GREEN}*/5 * * * *${NC}         ${DIM}every 5 minutes${NC}"
    echo -e "    ${GREEN}0 * * * *${NC}           ${DIM}every hour (on the hour)${NC}"
    echo -e "    ${GREEN}0 2 * * *${NC}           ${DIM}every day at 2:00 AM${NC}"
    echo -e "    ${GREEN}0 2 * * 1${NC}           ${DIM}every Monday at 2:00 AM${NC}"
    echo -e "    ${GREEN}0 0 1 * *${NC}           ${DIM}first day of every month at midnight${NC}"
    echo -e "    ${GREEN}*/15 * * * *${NC}        ${DIM}every 15 minutes${NC}"
    pause

    # ── 4.5 Practical: Cron + Rsync Backup ──
    section_header "4.5 — Putting It Together: Automated Backups"

    info "The killer combo: rsync + cron + SSH keys = automatic backups"
    echo ""
    info "Example: back up /var/www every 15 minutes to a backup server:"
    echo ""
    show_file "crontab -e" \
"# Backup web files every 15 minutes
*/15 * * * * rsync -az /var/www/html/ bob@10.0.0.5:/backup/www/ >> /var/log/backup.log 2>&1

# Backup /etc config files every hour
0 * * * * rsync -az /etc/ bob@10.0.0.5:/backup/etc/ >> /var/log/backup.log 2>&1

# Full backup daily at 3 AM
0 3 * * * rsync -az --delete /home/ bob@10.0.0.5:/backup/homes/ >> /var/log/backup.log 2>&1"
    echo ""
    explain "${BOLD}>> /var/log/backup.log 2>&1${NC} — logs output and errors to a file"
    explain "${BOLD}2>&1${NC} — redirects error messages to the same log file"
    echo ""
    warn "For this to work unattended, you MUST have SSH key auth set up"
    warn "(Module 2) — cron can't type passwords!"

    echo ""
    if ask_yn "View current cron jobs on this machine?"; then
        run_command "crontab -l 2>/dev/null || echo 'No crontab for current user'"
    fi
    pause

    # ── Exercise ──
    section_header "Exercise: Set Up Automated Backups"

    echo -e "  ${BOLD}Scenario:${NC} Your web server keeps getting attacked. Set up backups."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Write an rsync command to back up /var/www/html to /backup/www"
    echo "    2. Write a cron entry to run it every 10 minutes"
    echo "    3. Write a cron entry for daily /etc backup at midnight"
    echo "    4. Where do you redirect output for logging?"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "rsync -avz /var/www/html/ /backup/www/"
        echo ""
        show_file "crontab -e" \
"*/10 * * * * rsync -az /var/www/html/ /backup/www/ >> /var/log/rsync-www.log 2>&1
0 0 * * * rsync -az /etc/ /backup/etc/ >> /var/log/rsync-etc.log 2>&1"
    fi
    pause
}

# ── Module 5: Firewalls with UFW ────────────────────────────────────────────

module_ufw() {
    clear_screen
    section_header "Module 5: Firewalls with UFW"

    echo -e "  ${BOLD}UFW${NC} (Uncomplicated Firewall) is a friendly front-end"
    echo -e "  for ${BOLD}iptables${NC} — the actual Linux firewall. UFW makes it"
    echo -e "  simple to allow/block traffic without memorizing iptables syntax."
    echo ""
    echo -e "  In competition, your firewall is your ${BOLD}first line of defense${NC}."
    echo -e "  If a service shouldn't be accessible from outside, block it."
    pause

    # ── 5.1 Getting Started ──
    section_header "5.1 — UFW Basics"

    info "Install UFW (usually pre-installed on Ubuntu):"
    show_command "sudo apt install ufw"
    echo ""

    info "Check current status:"
    show_command "sudo ufw status verbose"
    echo ""

    warn "Before enabling UFW, ALWAYS allow SSH first!"
    warn "Otherwise you'll lock yourself out of a remote machine."
    echo ""
    show_command "sudo ufw allow ssh"
    echo -e "    ${DIM}or equivalently:${NC}"
    show_command "sudo ufw allow 22/tcp"
    echo ""

    info "Enable the firewall:"
    show_command "sudo ufw enable"
    echo ""

    info "Disable it (turns off all rules):"
    show_command "sudo ufw disable"
    echo ""

    info "Reset to defaults (remove all rules):"
    show_command "sudo ufw reset"

    echo ""
    if ask_yn "Check UFW status on this machine?"; then
        run_command "sudo ufw status verbose 2>/dev/null || echo 'UFW not installed or not available'"
    fi
    pause

    # ── 5.2 Default Policies ──
    section_header "5.2 — Default Policies"

    info "Default policies control what happens to traffic that"
    info "doesn't match any specific rule."
    echo ""
    explain "Deny all incoming (block everything unless explicitly allowed):"
    show_command "sudo ufw default deny incoming"
    echo ""
    explain "Allow all outgoing (let your machine talk to the internet):"
    show_command "sudo ufw default allow outgoing"
    echo ""
    success "This is the recommended setup: deny inbound, allow outbound."
    info "Then you only open the specific ports you need."
    pause

    # ── 5.3 Allow / Deny Rules ──
    section_header "5.3 — Creating Rules"

    info "Allow a specific port:"
    echo ""
    show_command "sudo ufw allow 80/tcp"
    echo -e "    ${DIM}Allow HTTP traffic (web server)${NC}"
    echo ""
    show_command "sudo ufw allow 443/tcp"
    echo -e "    ${DIM}Allow HTTPS traffic${NC}"
    echo ""
    show_command "sudo ufw allow 53"
    echo -e "    ${DIM}Allow DNS (both TCP and UDP — no protocol specified)${NC}"
    echo ""

    info "Allow by service name (UFW knows common services):"
    show_command "sudo ufw allow ssh"
    show_command "sudo ufw allow http"
    show_command "sudo ufw allow https"
    echo ""

    info "Deny a specific port:"
    show_command "sudo ufw deny 23/tcp"
    echo -e "    ${DIM}Block telnet${NC}"
    echo ""

    info "Allow from a specific IP only:"
    show_command "sudo ufw allow from 10.0.0.5"
    echo -e "    ${DIM}Allow ALL traffic from 10.0.0.5${NC}"
    echo ""
    show_command "sudo ufw allow from 10.0.0.0/24 to any port 22"
    echo -e "    ${DIM}Allow SSH only from the 10.0.0.x network${NC}"
    echo ""

    info "Deny from a specific IP:"
    show_command "sudo ufw deny from 192.168.1.100"
    echo -e "    ${DIM}Block all traffic from a suspicious IP${NC}"
    pause

    # ── 5.4 Viewing & Deleting Rules ──
    section_header "5.4 — Managing Rules"

    info "View rules with numbers (for deletion):"
    show_command "sudo ufw status numbered"
    echo ""
    echo -e "  ${DIM}Example output:${NC}"
    echo -e "  ${DIM}     To                   Action    From${NC}"
    echo -e "  ${DIM}     --                   ------    ----${NC}"
    echo -e "  ${DIM}[ 1] 22/tcp               ALLOW IN  Anywhere${NC}"
    echo -e "  ${DIM}[ 2] 80/tcp               ALLOW IN  Anywhere${NC}"
    echo -e "  ${DIM}[ 3] 443/tcp              ALLOW IN  Anywhere${NC}"
    echo -e "  ${DIM}[ 4] 23/tcp               DENY IN   Anywhere${NC}"
    echo ""

    info "Delete a rule by number:"
    show_command "sudo ufw delete 4"
    echo ""
    info "Delete a rule by specification:"
    show_command "sudo ufw delete allow 80/tcp"
    pause

    # ── 5.5 Competition Setup ──
    section_header "5.5 — Competition Firewall Setup"

    info "Typical competition firewall (only open what you need):"
    echo ""
    show_file "Competition UFW setup" \
"# Start fresh
sudo ufw reset

# Set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (so you don't lock yourself out)
sudo ufw allow 22/tcp

# Allow only what's needed for scoring
sudo ufw allow 80/tcp     # Web server
sudo ufw allow 443/tcp    # HTTPS
sudo ufw allow 53         # DNS (TCP + UDP)

# Block known bad actors
sudo ufw deny from 192.168.1.0/24

# Enable
sudo ufw enable

# Verify
sudo ufw status verbose"
    echo ""
    warn "Only open ports for services you're ${BOLD}actually running${NC}."
    warn "Every open port is an attack surface for red team."
    pause

    # ── Exercise ──
    section_header "Exercise: Firewall Configuration"

    echo -e "  ${BOLD}Scenario:${NC} Lock down a server running Apache + SSH + DNS."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Set default deny incoming, allow outgoing"
    echo "    2. Allow SSH from only the 10.0.0.0/24 network"
    echo "    3. Allow HTTP and HTTPS from anywhere"
    echo "    4. Allow DNS (both TCP and UDP)"
    echo "    5. Block all traffic from 192.168.66.0/24"
    echo "    6. Enable the firewall"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "sudo ufw default deny incoming"
        show_command "sudo ufw default allow outgoing"
        show_command "sudo ufw allow from 10.0.0.0/24 to any port 22 proto tcp"
        show_command "sudo ufw allow 80/tcp"
        show_command "sudo ufw allow 443/tcp"
        show_command "sudo ufw allow 53"
        show_command "sudo ufw deny from 192.168.66.0/24"
        show_command "sudo ufw enable"
        show_command "sudo ufw status numbered"
    fi
    pause
}

# ── Module 6: Active Connection Defense ──────────────────────────────────────

module_active_defense() {
    clear_screen
    section_header "Module 6: Active Connection Defense"

    echo -e "  During competition, red team is ${BOLD}actively${NC} attacking you."
    echo -e "  You need to know how to:"
    echo -e "    1. ${BOLD}See${NC} who's connected to your machine"
    echo -e "    2. ${BOLD}Identify${NC} suspicious connections"
    echo -e "    3. ${BOLD}Kill${NC} malicious processes"
    echo -e "    4. ${BOLD}Block${NC} attackers in real time"
    pause

    # ── 6.1 Viewing Connections ──
    section_header "6.1 — Seeing Active Connections"

    info "${BOLD}ss${NC} (socket statistics) — the modern replacement for netstat:"
    echo ""
    explain "Show all listening ports (what services are running?):"
    show_command "sudo ss -tlnp"
    echo ""
    echo -e "    ${BOLD}-t${NC}  TCP connections"
    echo -e "    ${BOLD}-l${NC}  listening (waiting for connections)"
    echo -e "    ${BOLD}-n${NC}  numeric (show port numbers, not names)"
    echo -e "    ${BOLD}-p${NC}  show the process using each port"
    echo ""

    try_it "sudo ss -tlnp"

    explain "Show all ESTABLISHED connections (who's connected right now?):"
    show_command "sudo ss -tnp"
    echo -e "    ${DIM}(no -l flag = show established, not just listening)${NC}"
    echo ""

    try_it "sudo ss -tnp"
    pause

    explain "Show all connections including UDP:"
    show_command "sudo ss -tulnp"
    echo -e "    ${DIM}-u adds UDP sockets${NC}"
    echo ""

    info "The older tool ${BOLD}netstat${NC} does the same thing:"
    show_command "sudo netstat -tulnp"
    echo -e "    ${DIM}Same flags, same meaning — some systems only have netstat${NC}"
    echo ""
    info "Install net-tools if netstat is missing:"
    show_command "sudo apt install net-tools"
    pause

    # ── 6.2 Reading Connection Output ──
    section_header "6.2 — Reading ss/netstat Output"

    info "Understanding what you're looking at:"
    echo ""
    echo -e "  ${DIM}State      Recv-Q Send-Q  Local Address:Port   Peer Address:Port  Process${NC}"
    echo -e "  ${DIM}LISTEN     0      128     0.0.0.0:22           0.0.0.0:*          sshd${NC}"
    echo -e "  ${DIM}LISTEN     0      511     0.0.0.0:80           0.0.0.0:*          apache2${NC}"
    echo -e "  ${DIM}ESTAB      0      0       10.0.0.5:22          10.0.0.100:54321   sshd${NC}"
    echo -e "  ${DIM}ESTAB      0      0       10.0.0.5:80          192.168.1.50:45678  apache2${NC}"
    echo ""
    echo -e "  ${BOLD}LISTEN${NC}  = port is open, waiting for connections"
    echo -e "  ${BOLD}ESTAB${NC}   = someone is actively connected"
    echo -e "  ${BOLD}0.0.0.0${NC} = listening on ALL interfaces"
    echo -e "  ${BOLD}Peer Address${NC} = who's connected (their IP:port)"
    echo ""
    warn "Things to look for:"
    echo -e "    ${RED}• Unexpected LISTEN ports (backdoors?)${NC}"
    echo -e "    ${RED}• Connections from unknown IPs${NC}"
    echo -e "    ${RED}• Unusual processes holding ports open${NC}"
    pause

    # ── 6.3 Finding Suspicious Processes ──
    section_header "6.3 — Finding Suspicious Processes"

    info "Once you spot a suspicious connection, trace it to a process:"
    echo ""
    explain "Find what's using a specific port:"
    show_command "sudo lsof -i :4444"
    echo -e "    ${DIM}Port 4444 is common for reverse shells (Metasploit default)${NC}"
    echo ""
    show_command "sudo ss -tlnp | grep 4444"
    echo ""

    explain "See all processes:"
    show_command "ps aux"
    echo ""
    explain "Find processes by name:"
    show_command "ps aux | grep apache"
    echo ""
    explain "Find processes by user (who's running weird stuff?):"
    show_command "ps aux | grep www-data"
    echo ""

    info "${BOLD}Common suspicious signs:${NC}"
    echo -e "    • Process running as ${BOLD}root${NC} that shouldn't be"
    echo -e "    • Process names like ${RED}nc${NC}, ${RED}ncat${NC}, ${RED}bash -i${NC}, ${RED}/tmp/something${NC}"
    echo -e "    • Connections to external IPs you don't recognize"
    echo -e "    • Processes running from ${RED}/tmp${NC}, ${RED}/dev/shm${NC}, or user home dirs"

    try_it "ps aux | head -20"
    pause

    # ── 6.4 Killing Connections ──
    section_header "6.4 — Killing Malicious Processes"

    info "Found something bad? Kill it:"
    echo ""
    explain "${BOLD}kill${NC} — send a signal to a process by PID:"
    show_command "kill 12345"
    echo -e "    ${DIM}Graceful termination (SIGTERM)${NC}"
    echo ""
    show_command "kill -9 12345"
    echo -e "    ${DIM}Force kill (SIGKILL) — use when regular kill doesn't work${NC}"
    echo ""

    explain "${BOLD}killall${NC} — kill all processes with a given name:"
    show_command "sudo killall nc"
    echo -e "    ${DIM}Kills ALL instances of netcat${NC}"
    echo ""

    explain "${BOLD}pkill${NC} — kill by pattern match:"
    show_command "sudo pkill -f 'reverse_shell'"
    echo -e "    ${DIM}-f matches against the full command line${NC}"
    echo ""

    warn "Be careful! Don't kill critical services like sshd."
    warn "Always verify the PID before killing."
    pause

    # ── 6.5 Real-Time Blocking ──
    section_header "6.5 — Blocking Attackers in Real Time"

    info "Spot an attacker? Block them immediately:"
    echo ""
    explain "Block with UFW:"
    show_command "sudo ufw deny from 192.168.1.100"
    echo ""
    explain "Block with iptables (if UFW isn't available):"
    show_command "sudo iptables -A INPUT -s 192.168.1.100 -j DROP"
    echo ""
    explain "Block a whole subnet:"
    show_command "sudo ufw deny from 192.168.1.0/24"
    echo ""

    info "Full incident response workflow:"
    echo ""
    echo -e "    ${CYAN}1.${NC} ${BOLD}Detect${NC}   — ${GREEN}sudo ss -tnp${NC}  (spot the connection)"
    echo -e "    ${CYAN}2.${NC} ${BOLD}Identify${NC}  — ${GREEN}sudo lsof -i :PORT${NC}  (find the process)"
    echo -e "    ${CYAN}3.${NC} ${BOLD}Kill${NC}      — ${GREEN}sudo kill -9 PID${NC}  (terminate it)"
    echo -e "    ${CYAN}4.${NC} ${BOLD}Block${NC}     — ${GREEN}sudo ufw deny from ATTACKER_IP${NC}"
    echo -e "    ${CYAN}5.${NC} ${BOLD}Verify${NC}    — ${GREEN}sudo ss -tnp${NC}  (confirm they're gone)"
    echo -e "    ${CYAN}6.${NC} ${BOLD}Investigate${NC} — check logs for how they got in"
    pause

    # ── 6.6 Monitoring Script ──
    section_header "6.6 — Quick Monitoring Commands"

    info "Commands to run periodically during competition:"
    echo ""
    show_command "watch -n 5 'ss -tnp'"
    echo -e "    ${DIM}Refreshes connection list every 5 seconds${NC}"
    echo ""
    show_command "sudo tcpdump -i eth0 -n"
    echo -e "    ${DIM}Live packet capture (very noisy but shows everything)${NC}"
    echo ""
    show_command "sudo tcpdump -i eth0 port 4444 -n"
    echo -e "    ${DIM}Watch for traffic on a specific port${NC}"
    echo ""
    show_command "last"
    echo -e "    ${DIM}Who has logged into this machine recently?${NC}"
    echo ""
    show_command "w"
    echo -e "    ${DIM}Who is logged in RIGHT NOW?${NC}"

    try_it "w"
    pause

    # ── Exercise ──
    section_header "Exercise: Incident Response Drill"

    echo -e "  ${BOLD}Scenario:${NC} You notice unusual network activity. Investigate."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. List all listening ports — anything unexpected?"
    echo "    2. List all established connections — any unknown IPs?"
    echo "    3. Check who is currently logged into the system"
    echo "    4. Find any processes running from /tmp (suspicious!)"
    echo "    5. Write the command to block IP 10.99.99.99"
    echo "    6. Write the command to kill process ID 31337"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "sudo ss -tlnp"
        show_command "sudo ss -tnp"
        show_command "w"
        show_command "ps aux | grep '/tmp/'"
        show_command "sudo ufw deny from 10.99.99.99"
        show_command "sudo kill -9 31337"

        if ask_yn "Run the safe commands now?"; then
            explain "Listening ports:"
            run_command "sudo ss -tlnp 2>/dev/null || sudo netstat -tlnp 2>/dev/null"
            explain "Established connections:"
            run_command "sudo ss -tnp 2>/dev/null || sudo netstat -tnp 2>/dev/null"
            explain "Logged-in users:"
            run_command "w"
            explain "Processes from /tmp:"
            run_command "ps aux | grep '/tmp/' | grep -v grep || echo 'None found (good!)'"
        fi
    fi
    pause
}

# ── Cheat Sheet ──────────────────────────────────────────────────────────────

cheat_sheet() {
    clear_screen
    section_header "Services & Security Quick Reference"

    echo -e "  ${BOLD}${CYAN}── SYSTEMCTL (Service Management) ──${NC}"
    echo -e "  ${GREEN}sudo systemctl start SERVICE${NC}       start now"
    echo -e "  ${GREEN}sudo systemctl stop SERVICE${NC}        stop now"
    echo -e "  ${GREEN}sudo systemctl restart SERVICE${NC}     restart"
    echo -e "  ${GREEN}sudo systemctl enable --now SVC${NC}    start + enable at boot"
    echo -e "  ${GREEN}sudo systemctl status SERVICE${NC}      check if running"
    echo ""
    echo -e "  ${BOLD}${CYAN}── APACHE ──${NC}"
    echo -e "  Install:   ${GREEN}sudo apt install apache2${NC}"
    echo -e "  Doc root:  ${GREEN}/var/www/html/${NC}"
    echo -e "  Config:    ${GREEN}/etc/apache2/apache2.conf${NC}"
    echo -e "  Vhosts:    ${GREEN}/etc/apache2/sites-available/${NC}"
    echo -e "  Enable:    ${GREEN}sudo a2ensite site.conf${NC}"
    echo -e "  Test cfg:  ${GREEN}sudo apache2ctl configtest${NC}"
    echo -e "  Logs:      ${GREEN}/var/log/apache2/{access,error}.log${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── SSH ──${NC}"
    echo -e "  Connect:   ${GREEN}ssh user@ip${NC}"
    echo -e "  Key gen:   ${GREEN}ssh-keygen -t ed25519${NC}"
    echo -e "  Copy key:  ${GREEN}ssh-copy-id user@ip${NC}"
    echo -e "  Config:    ${GREEN}/etc/ssh/sshd_config${NC}"
    echo -e "  Copy file: ${GREEN}scp file user@ip:/path/${NC}"
    echo -e "  Harden:    ${GREEN}PermitRootLogin no${NC}  +  ${GREEN}PasswordAuthentication no${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── DNS (BIND) ──${NC}"
    echo -e "  Install:   ${GREEN}sudo apt install bind9${NC}"
    echo -e "  Zones:     ${GREEN}/etc/bind/named.conf.local${NC}"
    echo -e "  Options:   ${GREEN}/etc/bind/named.conf.options${NC}"
    echo -e "  Check:     ${GREEN}sudo named-checkzone ZONE FILE${NC}"
    echo -e "  Test:      ${GREEN}dig @server domain${NC}  /  ${GREEN}nslookup domain server${NC}"
    echo -e "  Reverse:   ${GREEN}dig @server -x IP${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── RSYNC & CRON ──${NC}"
    echo -e "  Sync:      ${GREEN}rsync -avz source/ dest/${NC}"
    echo -e "  Remote:    ${GREEN}rsync -avz /path/ user@ip:/backup/${NC}"
    echo -e "  Dry run:   ${GREEN}rsync -av --dry-run source/ dest/${NC}"
    echo -e "  Edit cron: ${GREEN}crontab -e${NC}"
    echo -e "  View cron: ${GREEN}crontab -l${NC}"
    echo -e "  Every 15m: ${GREEN}*/15 * * * * command${NC}"
    echo -e "  Daily 3AM: ${GREEN}0 3 * * * command${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── UFW FIREWALL ──${NC}"
    echo -e "  Status:    ${GREEN}sudo ufw status numbered${NC}"
    echo -e "  Enable:    ${GREEN}sudo ufw enable${NC}"
    echo -e "  Defaults:  ${GREEN}sudo ufw default deny incoming${NC}"
    echo -e "  Allow:     ${GREEN}sudo ufw allow 80/tcp${NC}"
    echo -e "  Block IP:  ${GREEN}sudo ufw deny from BAD_IP${NC}"
    echo -e "  Delete:    ${GREEN}sudo ufw delete RULE_NUM${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── ACTIVE DEFENSE ──${NC}"
    echo -e "  Listening: ${GREEN}sudo ss -tlnp${NC}"
    echo -e "  Active:    ${GREEN}sudo ss -tnp${NC}"
    echo -e "  Port hunt: ${GREEN}sudo lsof -i :PORT${NC}"
    echo -e "  Kill:      ${GREEN}sudo kill -9 PID${NC}"
    echo -e "  Who's on:  ${GREEN}w${NC}"
    echo -e "  Logins:    ${GREEN}last${NC}"
    echo -e "  Sniff:     ${GREEN}sudo tcpdump -i eth0 -n${NC}"

    pause
}

# ── Main Menu ────────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        clear_screen
        banner

        echo -e "  ${BOLD}Modules:${NC}"
        echo ""
        echo -e "    ${CYAN}1${NC}  Web Services with Apache"
        echo -e "       ${DIM}Install, serve files, virtual hosts, logs${NC}"
        echo ""
        echo -e "    ${CYAN}2${NC}  SSH (Secure Shell)"
        echo -e "       ${DIM}Connect, keys, passwordless auth, hardening, scp${NC}"
        echo ""
        echo -e "    ${CYAN}3${NC}  DNS with BIND"
        echo -e "       ${DIM}Zones, records, forward/reverse, dig, nslookup${NC}"
        echo ""
        echo -e "    ${CYAN}4${NC}  Rsync & Cron (Automated Backups)"
        echo -e "       ${DIM}Rsync basics, over SSH, cron scheduling, combo${NC}"
        echo ""
        echo -e "    ${CYAN}5${NC}  Firewalls with UFW"
        echo -e "       ${DIM}Allow/deny rules, defaults, per-IP, competition setup${NC}"
        echo ""
        echo -e "    ${CYAN}6${NC}  Active Connection Defense"
        echo -e "       ${DIM}ss, netstat, lsof, kill, real-time blocking, incident response${NC}"
        echo ""
        echo -e "    ${CYAN}c${NC}  Cheat Sheet ${DIM}(quick reference)${NC}"
        echo ""
        echo -e "    ${CYAN}a${NC}  Run All Modules ${DIM}(full walkthrough)${NC}"
        echo ""
        echo -e "    ${CYAN}q${NC}  Quit"
        echo ""
        echo -ne "  ${CYAN}▸${NC} Select module: "
        read -r choice

        case "$choice" in
            1) module_apache ;;
            2) module_ssh ;;
            3) module_dns ;;
            4) module_rsync_cron ;;
            5) module_ufw ;;
            6) module_active_defense ;;
            c|C) cheat_sheet ;;
            a|A)
                module_apache
                module_ssh
                module_dns
                module_rsync_cron
                module_ufw
                module_active_defense
                cheat_sheet
                ;;
            q|Q)
                sandbox_cleanup
                echo ""
                echo -e "  ${GREEN}Defense wins championships. Stay vigilant.${NC}"
                echo ""
                exit 0
                ;;
            *) echo -e "  ${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# ── Entry Point ──────────────────────────────────────────────────────────────

main_menu
