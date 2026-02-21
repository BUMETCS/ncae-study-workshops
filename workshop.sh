#!/bin/bash
# ============================================================================
#  NCAE Cybersecurity Competition — Networking Workshop
#  Interactive training for Kali, Ubuntu, and MikroTik network configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# State
CURRENT_MODULE=""

# ── Helpers ──────────────────────────────────────────────────────────────────

clear_screen() {
    clear 2>/dev/null || printf '\033[2J\033[H'
}

banner() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}        NCAE Networking & Router Config Workshop            ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}        Kali · Ubuntu · MikroTik                            ${NC}${CYAN}║${NC}"
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

show_command() {
    echo -e "  ${DIM}\$${NC} ${GREEN}$1${NC}"
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

pause_prompt() {
    echo ""
    echo -ne "  ${DIM}$1${NC}"
    read -r
}

ask_yn() {
    echo -ne "  ${CYAN}?${NC} $1 [y/n]: "
    read -r answer
    [[ "$answer" =~ ^[Yy] ]]
}

# ── Module 1: Kali ──────────────────────────────────────────────────────────

module_kali() {
    clear_screen
    section_header "Module 1: Kali Linux Networking"

    echo -e "  Kali (Debian-based) uses ${BOLD}/etc/network/interfaces${NC} for"
    echo -e "  persistent network configuration. The primary interface"
    echo -e "  is typically ${BOLD}eth0${NC}."
    echo ""

    # ── 1.1 Static Config ──
    section_header "1.1 — Static IP Configuration"

    info "To set a static IP, edit ${BOLD}/etc/network/interfaces${NC}:"
    echo ""
    show_file "/etc/network/interfaces (static)" \
"auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.0.0.10
    netmask 255.255.255.0
    gateway 10.0.0.1"
    echo ""
    info "Then restart networking:"
    show_command "sudo systemctl restart networking"
    pause

    # ── 1.2 DHCP Config ──
    section_header "1.2 — DHCP Configuration"

    info "For DHCP, change ${BOLD}static${NC} to ${BOLD}dhcp${NC} and remove address lines:"
    echo ""
    show_file "/etc/network/interfaces (dhcp)" \
"auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp"
    echo ""
    info "Then restart networking:"
    show_command "sudo systemctl restart networking"
    pause

    # ── 1.3 Temporary IP ──
    section_header "1.3 — Temporary IP (does NOT survive reboot)"

    info "Add a temporary IP to an interface:"
    show_command "sudo ip addr add 10.0.0.10/24 dev eth0"
    echo ""
    info "Flush (remove) all IPs from an interface:"
    show_command "sudo ip addr flush dev eth0"
    echo ""
    warn "These changes are lost on reboot — useful for quick testing."
    pause

    # ── 1.4 Tun/Tap Interfaces ──
    section_header "1.4 — Creating Tun/Tap Interfaces"

    info "Create a TUN interface (Layer 3 tunneling):"
    show_command "sudo ip tuntap add user \$(whoami) mode tun tun0"
    echo ""
    info "Bring it up:"
    show_command "sudo ip link set tun0 up"
    echo ""
    info "Useful for tools like ${BOLD}chisel${NC}, ${BOLD}ligolo-ng${NC}, VPN tunnels, etc."
    pause

    # ── 1.5 Routing ──
    section_header "1.5 — Routing"

    info "View current routes:"
    show_command "ip route show"
    echo ""
    info "Add a route to a subnet:"
    show_command "sudo ip route add 192.168.1.0/24 dev eth0"
    echo ""
    info "Add a route via a specific gateway:"
    show_command "sudo ip route add 192.168.1.0/24 via 10.0.0.1 dev eth0"

    # ── Live demo if on actual VM ──
    echo ""
    if ask_yn "Run live demo? (shows current interfaces & routes)"; then
        section_header "Live: Current Network State"
        echo -e "  ${YELLOW}── Interfaces ──${NC}"
        ip -br addr 2>/dev/null | while IFS= read -r line; do
            echo "    $line"
        done
        echo ""
        echo -e "  ${YELLOW}── Routes ──${NC}"
        ip route show 2>/dev/null | while IFS= read -r line; do
            echo "    $line"
        done
    fi
    pause

    # ── Exercise ──
    section_header "Exercise: Kali Static IP"

    echo -e "  ${BOLD}Scenario:${NC} You need to assign your Kali machine the IP"
    echo -e "  ${BOLD}10.129.14.5/24${NC} with gateway ${BOLD}10.129.14.1${NC} on ${BOLD}eth0${NC}."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. What file do you edit?"
    echo "    2. Write the full config (static)"
    echo "    3. What command applies the change?"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        success "File: ${BOLD}/etc/network/interfaces${NC}"
        echo ""
        show_file "Answer" \
"auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.129.14.5
    netmask 255.255.255.0
    gateway 10.129.14.1"
        echo ""
        success "Apply: ${BOLD}sudo systemctl restart networking${NC}"
    fi
    pause
}

# ── Module 2: Ubuntu ────────────────────────────────────────────────────────

module_ubuntu() {
    clear_screen
    section_header "Module 2: Ubuntu Networking"

    echo -e "  Ubuntu uses ${BOLD}Netplan${NC} for network configuration."
    echo -e "  Config files live in ${BOLD}/etc/netplan/${NC} (YAML format)."
    echo -e "  Interfaces are typically named ${BOLD}ensXXX${NC} (e.g. ens18)."
    echo ""

    # ── 2.1 Netplan Static ──
    section_header "2.1 — Static IP with Netplan"

    info "Edit the netplan config:"
    show_command "sudo vim /etc/netplan/01-network-manager-all.yaml"
    echo ""
    show_file "/etc/netplan/01-network-manager-all.yaml (static)" \
"network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens18:
      addresses:
        - 10.0.0.10/24
      gateway4: 10.0.0.1"
    echo ""
    warn "YAML is indentation-sensitive — use spaces, NOT tabs!"
    echo ""
    info "Apply the config:"
    show_command "sudo netplan apply"
    pause

    # ── 2.2 nmtui ──
    section_header "2.2 — nmtui (The Easy Way)"

    info "${BOLD}nmtui${NC} is a terminal UI for NetworkManager."
    info "Much easier than hand-editing YAML for quick changes."
    echo ""
    show_command "sudo nmtui"
    echo ""
    echo -e "  ${DIM}┌──────────────────────────────────────────┐${NC}"
    echo -e "  ${DIM}│${NC}  ${BOLD}NetworkManager TUI${NC}                       ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}                                          ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}    ${CYAN}❯ Edit a connection${NC}                    ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}      Activate a connection               ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}      Set system hostname                 ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}                                          ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}                          ${DIM}<Quit>${NC}           ${DIM}│${NC}"
    echo -e "  ${DIM}└──────────────────────────────────────────┘${NC}"
    echo ""
    info "Select \"Edit a connection\" → pick your interface → set IP."
    info "Changes are applied immediately through NetworkManager."
    pause

    # ── 2.3 Temporary IP / iproute2 ──
    section_header "2.3 — Temporary IP & ip Commands"

    info "Same iproute2 commands as Kali (they both use the Linux kernel):"
    echo ""
    show_command "sudo ip addr add 10.0.0.10/24 dev ens18"
    show_command "sudo ip addr flush dev ens18"
    show_command "sudo ip route add 192.168.1.0/24 dev ens18"
    echo ""
    info "Tun/tap creation is identical too:"
    show_command "sudo ip tuntap add user \$(whoami) mode tun tun0"
    show_command "sudo ip link set tun0 up"
    pause

    # ── 2.4 Key differences from Kali ──
    section_header "2.4 — Kali vs Ubuntu Quick Reference"

    printf "  ${BOLD}%-25s %-20s %-20s${NC}\n" "" "Kali" "Ubuntu"
    printf "  ${DIM}%-25s${NC} %-20s %-20s\n" "Config file" "/etc/network/interfaces" "/etc/netplan/*.yaml"
    printf "  ${DIM}%-25s${NC} %-20s %-20s\n" "Apply changes" "systemctl restart net" "netplan apply"
    printf "  ${DIM}%-25s${NC} %-20s %-20s\n" "Easy GUI" "(none)" "nmtui"
    printf "  ${DIM}%-25s${NC} %-20s %-20s\n" "Interface name" "eth0" "ens18 / ensXXX"
    printf "  ${DIM}%-25s${NC} %-20s %-20s\n" "ip commands" "same" "same"
    pause

    # ── Exercise ──
    section_header "Exercise: Fix the Broken Netplan"

    echo -e "  ${BOLD}Scenario:${NC} A teammate wrote this netplan config but it"
    echo -e "  won't apply. Find and fix the errors:"
    echo ""
    show_file "BROKEN: /etc/netplan/01-network-manager-all.yaml" \
"network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens18:
      addresses:
      	- 10.0.0.10
      gateway4 10.0.0.1"
    echo ""
    echo -e "  ${CYAN}Hints:${NC}"
    echo "    • Check indentation (spaces vs tabs)"
    echo "    • Check the address format"
    echo "    • Check YAML syntax (missing colons?)"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        fail "Line 7: Tab used instead of spaces"
        fail "Line 7: Missing CIDR notation (need /24)"
        fail "Line 8: Missing colon after gateway4"
        echo ""
        show_file "FIXED" \
"network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens18:
      addresses:
        - 10.0.0.10/24
      gateway4: 10.0.0.1"
    fi
    pause
}

# ── Module 3: MikroTik ──────────────────────────────────────────────────────

module_mikrotik() {
    clear_screen
    section_header "Module 3: MikroTik RouterOS"

    echo -e "  MikroTik uses its own CLI (RouterOS). It looks different"
    echo -e "  from Linux but follows a consistent ${BOLD}/category/action${NC} pattern."
    echo ""
    warn "Default login: ${BOLD}admin${NC} / ${BOLD}(no password)${NC}"
    info "You'll be prompted to set a password on first login."
    pause

    # ── 3.1 Recon: See what you have ──
    section_header "3.1 — Reconnaissance: Interfaces & IPs"

    info "View available interfaces:"
    show_command "/interface print"
    echo ""
    echo -e "  ${DIM}Example output:${NC}"
    echo -e "  ${DIM}Flags: D - dynamic, X - disabled, R - running${NC}"
    echo -e "   ${DIM}#   NAME       TYPE   MTU  L2MTU${NC}"
    echo -e "   ${DIM}0 R ether1     ether  1500 1598${NC}"
    echo -e "   ${DIM}1 R ether2     ether  1500 1598${NC}"
    echo -e "   ${DIM}2 R ether3     ether  1500 1598${NC}"
    echo ""
    info "View current IP addresses:"
    show_command "/ip address print"
    echo ""
    warn "On a fresh install, this returns nothing — you have to assign IPs."
    pause

    # ── 3.2 Assign IPs ──
    section_header "3.2 — Assigning IP Addresses"

    info "Add an IP to an interface:"
    show_command "/ip address add address=10.0.0.1/24 interface=ether1"
    echo ""
    info "Remove an IP (by index number from ${BOLD}print${NC}):"
    show_command "/ip address remove 0"
    echo ""
    info "Verify:"
    show_command "/ip address print"
    echo ""
    warn "Figure out which ether port is internal vs external FIRST."
    info "Plug in one cable at a time and check ${BOLD}/interface print${NC} to see"
    info "which one shows 'R' (running)."
    pause

    # ── 3.3 Routing ──
    section_header "3.3 — Routing"

    info "View routes:"
    show_command "/ip route print"
    echo ""
    info "Add a default gateway:"
    show_command "/ip route add dst-address=0.0.0.0/0 gateway=10.0.0.1"
    echo ""
    info "Test connectivity:"
    show_command "/ping 10.0.0.1"
    pause

    # ── 3.4 Firewall & Services ──
    section_header "3.4 — Firewall & Services"

    info "Enable ICMP (ping) traffic:"
    show_command "/ip firewall filter add chain=input protocol=icmp action=accept"
    echo ""
    info "View running services:"
    show_command "/ip service print"
    echo ""
    echo -e "  ${DIM}Example output:${NC}"
    echo -e "   ${DIM}#  NAME     PORT  CERTIFICATE${NC}"
    echo -e "   ${DIM}0  telnet   23${NC}"
    echo -e "   ${DIM}1  ftp      21${NC}"
    echo -e "   ${DIM}2  www      80${NC}"
    echo -e "   ${DIM}3  ssh      22${NC}"
    echo -e "   ${DIM}4  www-ssl  443${NC}"
    echo -e "   ${DIM}5  api      8728${NC}"
    echo ""
    warn "Disable unnecessary services (FTP, Telnet are dangerous!):"
    show_command "/ip service disable 0"
    show_command "/ip service disable 1"
    pause

    # ── 3.5 NAT & Port Forwarding ──
    section_header "3.5 — NAT & Port Forwarding"

    info "MikroTik has a web GUI on port ${BOLD}8080${NC}."
    info "Once internal machines are up, you can use it for config."
    echo ""
    echo -e "  ${BOLD}GUI Method (Quick Set):${NC}"
    echo "    1. Browse to http://<router-ip>:8080"
    echo "    2. Check ${BOLD}Enable NAT${NC}"
    echo "    3. Check ${BOLD}Bridge All LAN Ports${NC}"
    echo "    4. Go to ${BOLD}Port Mapping${NC} under Quick Set"
    echo "    5. Forward port 80 → internal web server IP"
    echo ""
    echo -e "  ${BOLD}CLI Method:${NC}"
    show_command "/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1"
    echo ""
    info "Port forward (e.g. external:80 → internal web server):"
    show_command "/ip firewall nat add chain=dstnat protocol=tcp dst-port=80 action=dst-nat to-addresses=10.0.0.50 to-ports=80"
    pause

    # ── Exercise ──
    section_header "Exercise: Configure MikroTik from Scratch"

    echo -e "  ${BOLD}Scenario:${NC} Fresh MikroTik router. You have 3 interfaces:"
    echo -e "  ether1 (WAN), ether2 (LAN), ether3 (DMZ)"
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Assign 203.0.113.1/24 to ether1 (WAN)"
    echo "    2. Assign 10.0.0.1/24 to ether2 (LAN)"
    echo "    3. Assign 172.16.0.1/24 to ether3 (DMZ)"
    echo "    4. Set default gateway to 203.0.113.254"
    echo "    5. Enable NAT for LAN → WAN"
    echo "    6. Disable telnet and FTP"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "/ip address add address=203.0.113.1/24 interface=ether1"
        show_command "/ip address add address=10.0.0.1/24 interface=ether2"
        show_command "/ip address add address=172.16.0.1/24 interface=ether3"
        show_command "/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.254"
        show_command "/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1"
        show_command "/ip service disable 0"
        show_command "/ip service disable 1"
    fi
    pause
}

# ── Module 4: WiFi (Bonus) ──────────────────────────────────────────────────

module_wifi() {
    clear_screen
    section_header "Module 4: WiFi Configuration (Bonus)"

    echo -e "  The competition is ethernet-based, but knowing WiFi"
    echo -e "  config from the command line is useful in the field."
    echo ""

    # ── 4.1 wpa_supplicant + dhclient ──
    section_header "4.1 — wpa_supplicant + dhclient (Classic)"

    info "Scan for networks:"
    show_command "sudo iwlist wlan0 scan | grep ESSID"
    echo ""
    info "Create a config file:"
    show_command "wpa_passphrase \"NetworkName\" \"password\" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf"
    echo ""
    info "Connect:"
    show_command "sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf"
    echo ""
    info "Get an IP via DHCP:"
    show_command "sudo dhclient wlan0"
    echo ""
    info "Verify:"
    show_command "ip addr show wlan0"
    pause

    # ── 4.2 iwd ──
    section_header "4.2 — iwd (Modern Alternative)"

    info "${BOLD}iwd${NC} (iNet Wireless Daemon) is lighter and faster than"
    info "wpa_supplicant. Comes with an interactive shell: ${BOLD}iwctl${NC}"
    echo ""
    show_command "sudo systemctl start iwd"
    show_command "iwctl"
    echo ""
    echo -e "  ${DIM}Inside iwctl:${NC}"
    show_command "device list"
    show_command "station wlan0 scan"
    show_command "station wlan0 get-networks"
    show_command "station wlan0 connect \"NetworkName\""
    echo ""
    info "Then get an IP:"
    show_command "sudo dhclient wlan0"
    echo ""
    warn "iwd and wpa_supplicant conflict — only use one at a time."
    pause
}

# ── Cheat Sheet ─────────────────────────────────────────────────────────────

cheat_sheet() {
    clear_screen
    section_header "Quick Reference Cheat Sheet"

    echo -e "  ${BOLD}${CYAN}── KALI (Debian) ──${NC}"
    echo -e "  Config:   ${GREEN}/etc/network/interfaces${NC}"
    echo -e "  Apply:    ${GREEN}sudo systemctl restart networking${NC}"
    echo -e "  Temp IP:  ${GREEN}sudo ip addr add 10.0.0.5/24 dev eth0${NC}"
    echo -e "  Flush:    ${GREEN}sudo ip addr flush dev eth0${NC}"
    echo -e "  Route:    ${GREEN}sudo ip route add 192.168.1.0/24 dev eth0${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── UBUNTU ──${NC}"
    echo -e "  Config:   ${GREEN}/etc/netplan/01-network-manager-all.yaml${NC}"
    echo -e "  Apply:    ${GREEN}sudo netplan apply${NC}"
    echo -e "  Easy way: ${GREEN}sudo nmtui${NC}"
    echo -e "  Temp IP:  ${GREEN}sudo ip addr add 10.0.0.5/24 dev ens18${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── MIKROTIK ──${NC}"
    echo -e "  Login:    ${GREEN}admin / (no password)${NC}"
    echo -e "  See IFs:  ${GREEN}/interface print${NC}"
    echo -e "  See IPs:  ${GREEN}/ip address print${NC}"
    echo -e "  Add IP:   ${GREEN}/ip address add address=x.x.x.x/24 interface=etherX${NC}"
    echo -e "  Routes:   ${GREEN}/ip route print${NC}"
    echo -e "  Def GW:   ${GREEN}/ip route add dst-address=0.0.0.0/0 gateway=x.x.x.x${NC}"
    echo -e "  NAT:      ${GREEN}/ip firewall nat add chain=srcnat action=masquerade out-interface=ether1${NC}"
    echo -e "  Ping:     ${GREEN}/ping x.x.x.x${NC}"
    echo -e "  Services: ${GREEN}/ip service print${NC}"
    echo -e "  Disable:  ${GREEN}/ip service disable <#>${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── WIFI ──${NC}"
    echo -e "  Classic:  ${GREEN}wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf${NC}"
    echo -e "  DHCP:     ${GREEN}sudo dhclient wlan0${NC}"
    echo -e "  Modern:   ${GREEN}iwctl → station wlan0 connect \"SSID\"${NC}"
    echo ""
    echo -e "  ${BOLD}${CYAN}── UNIVERSAL (iproute2) ──${NC}"
    echo -e "  Show:     ${GREEN}ip addr show${NC}  /  ${GREEN}ip -br addr${NC}"
    echo -e "  Routes:   ${GREEN}ip route show${NC}"
    echo -e "  Add TUN:  ${GREEN}sudo ip tuntap add user \$(whoami) mode tun tun0${NC}"
    echo -e "  Link up:  ${GREEN}sudo ip link set tun0 up${NC}"

    pause
}

# ── Main Menu ────────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        clear_screen
        banner

        echo -e "  ${BOLD}Modules:${NC}"
        echo ""
        echo -e "    ${CYAN}1${NC}  Kali Linux Networking"
        echo -e "       ${DIM}Static/DHCP config, ip commands, tun/tap, routing${NC}"
        echo ""
        echo -e "    ${CYAN}2${NC}  Ubuntu Networking"
        echo -e "       ${DIM}Netplan, nmtui, ip commands, Kali↔Ubuntu comparison${NC}"
        echo ""
        echo -e "    ${CYAN}3${NC}  MikroTik Router Configuration"
        echo -e "       ${DIM}Interface setup, routing, firewall, NAT, port forwarding${NC}"
        echo ""
        echo -e "    ${CYAN}4${NC}  WiFi Configuration ${DIM}(bonus)${NC}"
        echo -e "       ${DIM}wpa_supplicant, dhclient, iwd${NC}"
        echo ""
        echo -e "    ${CYAN}c${NC}  Cheat Sheet ${DIM}(quick reference for competition day)${NC}"
        echo ""
        echo -e "    ${CYAN}q${NC}  Quit"
        echo ""
        echo -ne "  ${CYAN}▸${NC} Select module: "
        read -r choice

        case "$choice" in
            1) module_kali ;;
            2) module_ubuntu ;;
            3) module_mikrotik ;;
            4) module_wifi ;;
            c|C) cheat_sheet ;;
            q|Q) echo ""; echo -e "  ${GREEN}Happy hacking! 🏴‍☠️${NC}"; echo ""; exit 0 ;;
            *) echo -e "  ${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# ── Entry Point ──────────────────────────────────────────────────────────────

main_menu
