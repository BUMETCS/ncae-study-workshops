#!/bin/bash
# ============================================================================
#  NCAE Cybersecurity Competition — Intro to Bash Scripting Workshop
#  Interactive training: variables, input, logic, and a real IP changer tool
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX="/tmp/scripting-workshop"

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
    echo -e "${CYAN}║${NC}${BOLD}          NCAE Intro to Bash Scripting Workshop              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}          Variables · Logic · Files · Automation              ${NC}${CYAN}║${NC}"
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

# ── Module 1: Hello World ───────────────────────────────────────────────────

module_hello_world() {
    clear_screen
    section_header "Module 1: Your First Script"
    sandbox_setup

    echo -e "  A bash script is just a text file full of commands."
    echo -e "  Instead of typing commands one at a time, you write them"
    echo -e "  all in a file and run them together. That's it."
    echo ""
    echo -e "  It's like a recipe: step 1, step 2, step 3..."
    echo -e "  The computer follows the instructions top to bottom."
    pause

    # ── 1.1 The Shebang ──
    section_header "1.1 — The Shebang Line"

    info "Every script starts with a ${BOLD}shebang${NC} — a special first line"
    info "that tells the system which program should run this script."
    echo ""
    echo -e "  ${GREEN}#!/bin/bash${NC}"
    echo ""
    echo -e "  ${BOLD}#!${NC}   ← the shebang characters (hash + bang)"
    echo -e "  ${BOLD}/bin/bash${NC} ← path to the bash interpreter"
    echo ""
    info "Without this line, the system might try to run your script"
    info "with the wrong shell and things could break."
    echo ""
    warn "Always put this as the ${BOLD}very first line${NC} — no blank lines above it."
    pause

    # ── 1.2 Writing Hello World ──
    section_header "1.2 — Writing & Running Hello World"

    info "Let's create our first script:"
    echo ""
    show_file "hello.sh" \
'#!/bin/bash
echo "Hello, World!"
echo "My name is $(whoami)"
echo "Today is $(date)"
echo "I am on $(hostname)"'
    echo ""

    if ask_yn "Create and run this script?"; then
        cat > "$SANDBOX/hello.sh" << 'SCRIPT'
#!/bin/bash
echo "Hello, World!"
echo "My name is $(whoami)"
echo "Today is $(date)"
echo "I am on $(hostname)"
SCRIPT
        success "Created $SANDBOX/hello.sh"
        echo ""

        explain "Step 1: Make it executable with chmod:"
        run_command "chmod +x $SANDBOX/hello.sh"

        explain "Step 2: Run it:"
        run_command "$SANDBOX/hello.sh"
    fi
    pause

    # ── 1.3 Making Scripts Executable ──
    section_header "1.3 — Making Scripts Executable"

    info "A script is just a text file. To RUN it, you need to:"
    echo ""
    echo -e "  ${BOLD}Option 1:${NC} Make it executable (the proper way)"
    show_command "chmod +x myscript.sh"
    show_command "./myscript.sh"
    echo ""
    echo -e "  ${BOLD}Option 2:${NC} Call bash directly (works without chmod)"
    show_command "bash myscript.sh"
    echo ""

    warn "The ${BOLD}./${NC} prefix is important — it tells the shell to look"
    warn "in the current directory. Without it, it searches your PATH."
    echo ""
    info "If you see ${RED}Permission denied${NC}, you forgot ${BOLD}chmod +x${NC}."
    info "If you see ${RED}command not found${NC}, you forgot ${BOLD}./${NC} (or the shebang)."
    pause

    # ── 1.4 Comments ──
    section_header "1.4 — Comments"

    info "Lines starting with ${BOLD}#${NC} are comments — ignored by bash."
    info "Use them to explain what your script does."
    echo ""
    show_file "good_comments.sh" \
'#!/bin/bash
# This script backs up the web directory
# Run it with: sudo ./backup.sh

# Create the backup directory if it doesnt exist
mkdir -p /backup/www

# Copy web files to backup
rsync -av /var/www/html/ /backup/www/

# Log the timestamp
echo "Backup completed at $(date)" >> /var/log/backup.log'
    echo ""
    info "Comments are free documentation. Use them generously."
    pause
}

# ── Module 2: Variables & User Input ─────────────────────────────────────────

module_variables() {
    clear_screen
    section_header "Module 2: Variables & User Input"
    sandbox_setup

    echo -e "  Variables are containers that hold values — text, numbers,"
    echo -e "  file paths, command output. They let your script be flexible"
    echo -e "  instead of hard-coding everything."
    pause

    # ── 2.1 Setting Variables ──
    section_header "2.1 — Creating Variables"

    info "Assign a variable with ${BOLD}=${NC} (NO spaces around the =):"
    echo ""
    echo -e "    ${GREEN}name=\"Bob\"${NC}          ${DIM}← correct${NC}"
    echo -e "    ${RED}name = \"Bob\"${NC}        ${DIM}← WRONG (bash thinks 'name' is a command)${NC}"
    echo ""

    try_it "name='Workshop Student' && echo \"Hello, \$name!\""

    echo ""
    info "Use ${BOLD}\$variable${NC} or ${BOLD}\${variable}${NC} to read the value:"
    echo ""
    echo -e "    ${GREEN}echo \$name${NC}          ${DIM}← works for simple cases${NC}"
    echo -e "    ${GREEN}echo \${name}${NC}        ${DIM}← safer — prevents ambiguity${NC}"
    echo -e "    ${GREEN}echo \"\${name}_file\"${NC}  ${DIM}← use braces when followed by other text${NC}"
    echo ""

    try_it "server='web01' && echo \"Backup of \${server}_config complete\""
    pause

    # ── 2.2 Command Substitution ──
    section_header "2.2 — Capturing Command Output"

    info "Store a command's output in a variable with ${BOLD}\$(command)${NC}:"
    echo ""

    try_it "current_user=\$(whoami) && echo \"Running as: \$current_user\""

    try_it "today=\$(date +%Y-%m-%d) && echo \"Today is: \$today\""

    try_it "ip_addr=\$(hostname -I | awk '{print \$1}') && echo \"My IP is: \$ip_addr\""

    echo ""
    info "The older syntax uses backticks: ${BOLD}\`command\`${NC}"
    echo -e "    ${GREEN}today=\`date\`${NC}    ${DIM}← works but harder to read and nest${NC}"
    echo -e "    ${GREEN}today=\$(date)${NC}   ${DIM}← preferred — clearer and nestable${NC}"
    pause

    # ── 2.3 Special Variables ──
    section_header "2.3 — Special Built-in Variables"

    info "Bash gives you several variables for free:"
    echo ""
    echo -e "    ${BOLD}\$0${NC}     the script's own name"
    echo -e "    ${BOLD}\$1${NC}     first argument passed to the script"
    echo -e "    ${BOLD}\$2${NC}     second argument"
    echo -e "    ${BOLD}\$#${NC}     number of arguments"
    echo -e "    ${BOLD}\$@${NC}     all arguments as separate words"
    echo -e "    ${BOLD}\$?${NC}     exit code of the last command (0 = success)"
    echo -e "    ${BOLD}\$\$${NC}     the script's process ID (PID)"
    echo -e "    ${BOLD}\$USER${NC}  current username"
    echo -e "    ${BOLD}\$HOME${NC}  home directory"
    echo -e "    ${BOLD}\$PWD${NC}   current directory"
    echo ""

    if ask_yn "Create a demo script that uses these?"; then
        cat > "$SANDBOX/args_demo.sh" << 'SCRIPT'
#!/bin/bash
echo "Script name:   $0"
echo "First arg:     $1"
echo "Second arg:    $2"
echo "Num of args:   $#"
echo "All args:      $@"
echo "Current user:  $USER"
echo "Home dir:      $HOME"
SCRIPT
        chmod +x "$SANDBOX/args_demo.sh"
        run_command "$SANDBOX/args_demo.sh hello world"
    fi
    pause

    # ── 2.4 User Input ──
    section_header "2.4 — Getting Input from the User"

    info "${BOLD}read${NC} pauses the script and waits for the user to type something:"
    echo ""
    show_file "ask_name.sh" \
'#!/bin/bash
echo "What is your name?"
read username
echo "Hello, $username! Welcome to the workshop."'
    echo ""

    info "Useful read flags:"
    echo ""
    echo -e "    ${GREEN}read -p \"Prompt: \" var${NC}    ${DIM}← print prompt on same line${NC}"
    echo -e "    ${GREEN}read -s password${NC}          ${DIM}← silent mode (hide typing, for passwords)${NC}"
    echo -e "    ${GREEN}read -t 10 answer${NC}         ${DIM}← timeout after 10 seconds${NC}"
    echo ""

    if ask_yn "Create an interactive demo script?"; then
        cat > "$SANDBOX/input_demo.sh" << 'SCRIPT'
#!/bin/bash
read -p "Enter your name: " name
read -p "Enter your team: " team
echo ""
echo "Welcome, $name from $team!"
echo "You're logged in as $(whoami) on $(hostname)"
SCRIPT
        chmod +x "$SANDBOX/input_demo.sh"
        run_command "$SANDBOX/input_demo.sh"
    fi
    pause

    # ── 2.5 Quoting Rules ──
    section_header "2.5 — Quoting: Single vs Double Quotes"

    info "This trips up a LOT of people:"
    echo ""
    echo -e "  ${BOLD}Double quotes \"...\"${NC} — variables ARE expanded"
    echo -e "    ${GREEN}echo \"Hello, \$USER\"${NC}  →  Hello, bob"
    echo ""
    echo -e "  ${BOLD}Single quotes '...'${NC} — everything is literal, NO expansion"
    echo -e "    ${GREEN}echo 'Hello, \$USER'${NC}  →  Hello, \$USER"
    echo ""

    try_it "echo \"Double: \$USER\" && echo 'Single: \$USER'"

    echo ""
    info "Rule of thumb:"
    echo -e "    Use ${BOLD}double quotes${NC} when you want variables to expand"
    echo -e "    Use ${BOLD}single quotes${NC} when you want exact literal text"
    pause

    # ── Exercise ──
    section_header "Exercise: Variable Practice"

    echo -e "  ${BOLD}Tasks:${NC}"
    echo ""
    echo "    1. Write a script that:"
    echo "       - Stores your IP address in a variable"
    echo "       - Stores today's date in a variable"
    echo "       - Stores the hostname in a variable"
    echo "       - Prints: 'Server HOSTNAME has IP ADDRESS as of DATE'"
    echo ""
    echo "    2. Modify it to accept the IP as a command-line argument (\$1)"
    echo "       instead of detecting it"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_file "server_info.sh (auto-detect)" \
'#!/bin/bash
my_ip=$(hostname -I | awk '"'"'{print $1}'"'"')
today=$(date +"%Y-%m-%d %H:%M")
host=$(hostname)
echo "Server $host has IP $my_ip as of $today"'
        echo ""
        show_file "server_info.sh (argument)" \
'#!/bin/bash
my_ip=$1
today=$(date +"%Y-%m-%d %H:%M")
host=$(hostname)

if [ -z "$my_ip" ]; then
    echo "Usage: $0 <ip-address>"
    exit 1
fi

echo "Server $host has IP $my_ip as of $today"'
    fi
    pause
}

# ── Module 3: Conditionals & Logic ──────────────────────────────────────────

module_conditionals() {
    clear_screen
    section_header "Module 3: Conditionals & Logic"
    sandbox_setup

    echo -e "  Scripts need to make decisions: \"If this is true, do that."
    echo -e "  Otherwise, do something else.\" That's what ${BOLD}if/else${NC} does."
    pause

    # ── 3.1 If/Else ──
    section_header "3.1 — If / Else Statements"

    info "Basic structure:"
    echo ""
    show_file "if-else syntax" \
'if [ condition ]; then
    # do this if true
elif [ other_condition ]; then
    # do this if the first was false but this is true
else
    # do this if nothing matched
fi'
    echo ""
    warn "Spaces inside the brackets are REQUIRED!"
    echo -e "    ${GREEN}[ \$x -eq 5 ]${NC}   ${DIM}← correct${NC}"
    echo -e "    ${RED}[\$x -eq 5]${NC}    ${DIM}← WRONG (will error)${NC}"
    echo ""

    if ask_yn "Create a demo?"; then
        cat > "$SANDBOX/check_root.sh" << 'SCRIPT'
#!/bin/bash
if [ "$(whoami)" = "root" ]; then
    echo "You are root. Full power!"
else
    echo "You are NOT root. Run with sudo."
fi
SCRIPT
        chmod +x "$SANDBOX/check_root.sh"
        run_command "$SANDBOX/check_root.sh"
    fi
    pause

    # ── 3.2 Test Operators ──
    section_header "3.2 — Comparison Operators"

    info "${BOLD}String comparisons:${NC}"
    echo ""
    echo -e "    ${GREEN}[ \"\$a\" = \"\$b\" ]${NC}     strings are equal"
    echo -e "    ${GREEN}[ \"\$a\" != \"\$b\" ]${NC}    strings are NOT equal"
    echo -e "    ${GREEN}[ -z \"\$a\" ]${NC}          string is empty"
    echo -e "    ${GREEN}[ -n \"\$a\" ]${NC}          string is NOT empty"
    echo ""

    info "${BOLD}Number comparisons:${NC}"
    echo ""
    echo -e "    ${GREEN}[ \$a -eq \$b ]${NC}   equal"
    echo -e "    ${GREEN}[ \$a -ne \$b ]${NC}   not equal"
    echo -e "    ${GREEN}[ \$a -gt \$b ]${NC}   greater than"
    echo -e "    ${GREEN}[ \$a -lt \$b ]${NC}   less than"
    echo -e "    ${GREEN}[ \$a -ge \$b ]${NC}   greater or equal"
    echo -e "    ${GREEN}[ \$a -le \$b ]${NC}   less or equal"
    echo ""

    info "${BOLD}File tests:${NC} (super useful for scripts!)"
    echo ""
    echo -e "    ${GREEN}[ -f \"/path/file\" ]${NC}   file exists and is a regular file"
    echo -e "    ${GREEN}[ -d \"/path/dir\" ]${NC}    directory exists"
    echo -e "    ${GREEN}[ -e \"/path\" ]${NC}         path exists (file or directory)"
    echo -e "    ${GREEN}[ -r \"/path\" ]${NC}         file is readable"
    echo -e "    ${GREEN}[ -w \"/path\" ]${NC}         file is writable"
    echo -e "    ${GREEN}[ -x \"/path\" ]${NC}         file is executable"
    echo -e "    ${GREEN}[ -s \"/path\" ]${NC}         file exists and is NOT empty"
    pause

    if ask_yn "Create a file-checking demo?"; then
        cat > "$SANDBOX/file_check.sh" << 'SCRIPT'
#!/bin/bash
target="/etc/passwd"

if [ -f "$target" ]; then
    echo "$target exists!"
    lines=$(wc -l < "$target")
    echo "It has $lines lines."

    if [ -r "$target" ]; then
        echo "You CAN read it."
    else
        echo "You CANNOT read it (permission denied)."
    fi
else
    echo "$target does not exist."
fi
SCRIPT
        chmod +x "$SANDBOX/file_check.sh"
        run_command "$SANDBOX/file_check.sh"
    fi
    pause

    # ── 3.3 AND / OR ──
    section_header "3.3 — Combining Conditions (AND / OR)"

    info "Combine tests with ${BOLD}&&${NC} (AND) and ${BOLD}||${NC} (OR):"
    echo ""
    show_file "Example: both must be true" \
'if [ -f "/etc/passwd" ] && [ -r "/etc/passwd" ]; then
    echo "File exists AND is readable"
fi'
    echo ""
    show_file "Example: either can be true" \
'if [ "$1" = "start" ] || [ "$1" = "restart" ]; then
    echo "Starting the service..."
fi'
    echo ""
    info "You can also use ${BOLD}[[ ]]${NC} (double brackets) for more features:"
    echo -e "    ${GREEN}[[ \$name == \"bob\" && \$age -gt 20 ]]${NC}"
    echo -e "    ${DIM}Double brackets support && and || inside, regex with =~, etc.${NC}"
    pause

    # ── 3.4 Exit Codes ──
    section_header "3.4 — Exit Codes"

    info "Every command returns an ${BOLD}exit code${NC} when it finishes:"
    echo ""
    echo -e "    ${GREEN}0${NC}   = success (everything went fine)"
    echo -e "    ${RED}1+${NC}  = failure (something went wrong)"
    echo ""
    info "${BOLD}\$?${NC} holds the exit code of the last command:"
    echo ""

    try_it "ls /etc/passwd && echo \"Exit code: \$?\""
    try_it "ls /nonexistent/file 2>/dev/null; echo \"Exit code: \$?\""

    echo ""
    info "Use ${BOLD}exit${NC} in your scripts to set the exit code:"
    echo ""
    show_file "exit code example" \
'#!/bin/bash
if [ -z "$1" ]; then
    echo "Error: no argument provided"
    exit 1    # failure
fi
echo "You said: $1"
exit 0        # success'
    pause
}

# ── Module 4: Loops ──────────────────────────────────────────────────────────

module_loops() {
    clear_screen
    section_header "Module 4: Loops & Iteration"
    sandbox_setup

    echo -e "  Loops let you repeat actions — process a list of servers,"
    echo -e "  check multiple files, retry a command. They turn a 50-line"
    echo -e "  script into a 5-line script."
    pause

    # ── 4.1 For Loops ──
    section_header "4.1 — For Loops"

    info "A ${BOLD}for${NC} loop repeats for each item in a list:"
    echo ""
    show_file "basic for loop" \
'for name in alice bob charlie; do
    echo "Hello, $name!"
done'

    if ask_yn "Run this?"; then
        run_command "for name in alice bob charlie; do echo \"Hello, \$name!\"; done"
    fi
    echo ""

    explain "Loop over files in a directory:"
    show_file "loop over files" \
'for file in /etc/*.conf; do
    echo "Config file: $file"
done'

    try_it "for file in /etc/*.conf; do echo \"Found: \$file\"; done 2>/dev/null | head -10"
    pause

    explain "Loop over a range of numbers:"
    echo ""
    show_command "for i in {1..5}; do echo \"Count: \$i\"; done"
    try_it "for i in {1..5}; do echo \"Count: \$i\"; done"

    echo ""
    explain "Loop with seq (more flexible):"
    show_command "for i in \$(seq 1 2 10); do echo \"Odd: \$i\"; done"
    echo -e "    ${DIM}seq START STEP END — count from 1 to 10 by 2${NC}"
    try_it "for i in \$(seq 1 2 10); do echo \"Odd: \$i\"; done"
    pause

    # ── 4.2 While Loops ──
    section_header "4.2 — While Loops"

    info "A ${BOLD}while${NC} loop repeats as long as a condition is true:"
    echo ""
    show_file "while loop" \
'count=1
while [ $count -le 5 ]; do
    echo "Attempt $count"
    count=$((count + 1))
done'

    if ask_yn "Run this?"; then
        run_command "count=1; while [ \$count -le 5 ]; do echo \"Attempt \$count\"; count=\$((count + 1)); done"
    fi
    echo ""

    explain "Read a file line by line (very common!):"
    show_file "read file line by line" \
'while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hostname'

    try_it "while IFS= read -r line; do echo \"Line: \$line\"; done < /etc/hostname"
    pause

    explain "Practical: retry a command until it works:"
    show_file "retry loop" \
'#!/bin/bash
max_retries=5
attempt=1

while [ $attempt -le $max_retries ]; do
    echo "Attempt $attempt: pinging server..."
    if ping -c 1 -W 2 10.0.0.1 > /dev/null 2>&1; then
        echo "Server is up!"
        break
    fi
    echo "Failed. Retrying in 3 seconds..."
    sleep 3
    attempt=$((attempt + 1))
done

if [ $attempt -gt $max_retries ]; then
    echo "Server unreachable after $max_retries attempts."
fi'
    echo ""
    info "${BOLD}break${NC} exits the loop early (when you've found what you need)."
    info "${BOLD}continue${NC} skips to the next iteration."
    pause

    # ── 4.3 Practical: Loop Over Servers ──
    section_header "4.3 — Practical: Loop Over Servers"

    info "A script that pings all machines in your network:"
    echo ""
    show_file "ping_sweep.sh" \
'#!/bin/bash
echo "Scanning 10.0.0.0/24..."

for i in $(seq 1 254); do
    ip="10.0.0.$i"
    if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
        echo "[UP]   $ip"
    fi
done

echo "Scan complete."'
    echo ""
    info "This is a basic ping sweep — useful for finding live hosts."
    info "Takes a while because it checks all 254 addresses one at a time."
    pause

    # ── Exercise ──
    section_header "Exercise: Loop Practice"

    echo -e "  ${BOLD}Tasks:${NC}"
    echo ""
    echo "    1. Write a for loop that creates 5 files:"
    echo "       /tmp/scripting-workshop/file1.txt through file5.txt"
    echo ""
    echo "    2. Write a for loop that reads each file and prints"
    echo "       the filename + line count"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_file "create files" \
'for i in {1..5}; do
    echo "Data for file $i" > /tmp/scripting-workshop/file${i}.txt
done'
        echo ""
        show_file "count lines" \
'for f in /tmp/scripting-workshop/file*.txt; do
    lines=$(wc -l < "$f")
    echo "$f has $lines lines"
done'

        if ask_yn "Run it?"; then
            run_command "for i in {1..5}; do echo \"Data for file \$i\" > /tmp/scripting-workshop/file\${i}.txt; done && echo 'Files created:' && ls /tmp/scripting-workshop/file*.txt"
            run_command "for f in /tmp/scripting-workshop/file*.txt; do lines=\$(wc -l < \"\$f\"); echo \"\$f has \$lines lines\"; done"
        fi
    fi
    pause
}

# ── Module 5: Functions & Script Structure ───────────────────────────────────

module_functions() {
    clear_screen
    section_header "Module 5: Functions & Root Permissions"
    sandbox_setup

    echo -e "  Functions let you organize your script into reusable blocks."
    echo -e "  Instead of copy-pasting the same code, write it once as"
    echo -e "  a function and call it by name."
    pause

    # ── 5.1 Writing Functions ──
    section_header "5.1 — Writing Functions"

    info "Two valid syntaxes (both work the same):"
    echo ""
    show_file "function syntax" \
'# Style 1 (explicit keyword)
function greet {
    echo "Hello, $1!"
}

# Style 2 (parentheses — more common)
greet() {
    echo "Hello, $1!"
}

# Call it:
greet "Bob"
greet "Alice"'
    echo ""
    info "Functions get their own ${BOLD}\$1, \$2, \$#${NC} — separate from the script's."
    echo ""

    if ask_yn "Create a demo?"; then
        cat > "$SANDBOX/functions_demo.sh" << 'SCRIPT'
#!/bin/bash

log_info() {
    echo "[INFO] $(date +%H:%M:%S) - $1"
}

log_error() {
    echo "[ERROR] $(date +%H:%M:%S) - $1" >&2
}

check_service() {
    local service="$1"
    if systemctl is-active "$service" > /dev/null 2>&1; then
        log_info "$service is running"
    else
        log_error "$service is NOT running"
    fi
}

log_info "Starting service checks..."
check_service "sshd"
check_service "apache2"
check_service "nonexistent-service"
log_info "Checks complete."
SCRIPT
        chmod +x "$SANDBOX/functions_demo.sh"
        run_command "$SANDBOX/functions_demo.sh"
    fi
    pause

    # ── 5.2 Local Variables ──
    section_header "5.2 — Local Variables"

    info "Use ${BOLD}local${NC} inside functions to avoid polluting global scope:"
    echo ""
    show_file "local variables" \
'count_files() {
    local dir="$1"
    local count=$(ls -1 "$dir" 2>/dev/null | wc -l)
    echo "$dir has $count items"
}

count_files /etc
count_files /tmp'
    echo ""
    explain "${BOLD}local${NC} means the variable only exists inside the function."
    explain "Without it, the variable leaks into the rest of the script."
    pause

    # ── 5.3 Root Checks ──
    section_header "5.3 — Checking for Root Permissions"

    info "Many scripts need root (sudo) to work. Always check first:"
    echo ""
    show_file "root check (recommended)" \
'#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

echo "Running as root — proceeding..."
# ... rest of the script ...'
    echo ""
    explain "${BOLD}\$EUID${NC} = effective user ID. Root is always 0."
    echo ""

    info "Alternative check:"
    show_file "alternative root check" \
'if [ "$(whoami)" != "root" ]; then
    echo "Please run with sudo."
    exit 1
fi'
    echo ""

    if ask_yn "Create a demo?"; then
        cat > "$SANDBOX/needs_root.sh" << 'SCRIPT'
#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    echo "Try: sudo $0"
    exit 1
fi

echo "Root confirmed! Doing important system stuff..."
echo "Users on this system: $(wc -l < /etc/passwd)"
SCRIPT
        chmod +x "$SANDBOX/needs_root.sh"
        explain "Running without sudo (should fail):"
        run_command "$SANDBOX/needs_root.sh"
    fi
    pause

    # ── 5.4 Script Template ──
    section_header "5.4 — A Good Script Template"

    info "Here's a solid starting point for any script:"
    echo ""
    show_file "template.sh" \
'#!/bin/bash
# Description: What this script does
# Usage: ./script.sh <arg1> <arg2>
# Author: Your Name
# Date: 2025-01-15

set -euo pipefail

# -e   exit immediately on any error
# -u   treat unset variables as errors
# -o pipefail   catch errors in piped commands

# ── Variables ──
LOG_FILE="/var/log/myscript.log"

# ── Functions ──
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

die() {
    echo "ERROR: $1" >&2
    exit 1
}

# ── Main ──
[ "$EUID" -eq 0 ] || die "Must run as root"
[ $# -ge 1 ] || die "Usage: $0 <argument>"

log "Script started with args: $@"
# ... your code here ...
log "Script completed successfully"'
    echo ""
    warn "${BOLD}set -euo pipefail${NC} is a best practice. It makes your script"
    warn "fail loudly instead of silently continuing after errors."
    pause
}

# ── Module 6: Capstone — IP Changer Script ───────────────────────────────────

module_ip_changer() {
    clear_screen
    section_header "Module 6: Capstone — Scripted IP Changer"
    sandbox_setup

    echo -e "  Let's put everything together and build a real, useful tool:"
    echo -e "  a script that changes your machine's IP address."
    echo ""
    echo -e "  This is exactly the kind of script you'd use in competition"
    echo -e "  to quickly reconfigure network settings."
    pause

    # ── 6.1 The Plan ──
    section_header "6.1 — What It Needs to Do"

    echo -e "  ${BOLD}Features:${NC}"
    echo "    1. Check if running as root"
    echo "    2. Show current IP configuration"
    echo "    3. Ask the user for new IP, subnet, and gateway"
    echo "    4. Detect the OS (Kali vs Ubuntu) to use the right method"
    echo "    5. Apply the new configuration"
    echo "    6. Verify the change worked"
    echo ""
    info "This touches everything we've learned: variables, input,"
    info "conditionals, functions, file paths, and root permissions."
    pause

    # ── 6.2 Building It Step by Step ──
    section_header "6.2 — Building It Piece by Piece"

    explain "Step 1: Root check + shebang"
    show_file "ip_changer.sh — step 1" \
'#!/bin/bash
# IP Changer - quickly reconfigure network interfaces

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo: sudo $0"
    exit 1
fi'
    pause

    explain "Step 2: Detect the interface and current IP"
    show_file "ip_changer.sh — step 2" \
'# Find the primary network interface (skip loopback)
IFACE=$(ip route | grep default | awk '"'"'{print $5}'"'"' | head -1)

if [ -z "$IFACE" ]; then
    IFACE=$(ip -br link | grep -v lo | awk '"'"'{print $1}'"'"' | head -1)
fi

CURRENT_IP=$(ip -4 addr show "$IFACE" | grep inet | awk '"'"'{print $2}'"'"')

echo "Interface: $IFACE"
echo "Current IP: $CURRENT_IP"'
    pause

    explain "Step 3: Get user input"
    show_file "ip_changer.sh — step 3" \
'read -p "New IP address (e.g. 10.0.0.10): " NEW_IP
read -p "Subnet mask in CIDR (e.g. 24): " SUBNET
read -p "Gateway (e.g. 10.0.0.1): " GATEWAY

# Validate input
if [ -z "$NEW_IP" ] || [ -z "$SUBNET" ] || [ -z "$GATEWAY" ]; then
    echo "ERROR: All fields are required."
    exit 1
fi'
    pause

    explain "Step 4: Detect OS and apply the right way"
    show_file "ip_changer.sh — step 4" \
'# Detect distro
if [ -f /etc/debian_version ]; then
    if command -v netplan > /dev/null 2>&1; then
        DISTRO="ubuntu"
    else
        DISTRO="kali"
    fi
elif [ -f /etc/redhat-release ]; then
    DISTRO="centos"
else
    DISTRO="unknown"
fi

echo "Detected OS: $DISTRO"'
    pause

    # ── 6.3 The Full Script ──
    section_header "6.3 — The Complete Script"

    info "Here's the full IP changer, ready to use:"
    echo ""

    if ask_yn "Create the full script? (you can read through it)"; then
        cat > "$SANDBOX/ip_changer.sh" << 'FULLSCRIPT'
#!/bin/bash
# ============================================================================
# IP Changer — quickly reconfigure a network interface
# Usage: sudo ./ip_changer.sh
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# ── Root check ──
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR:${NC} Run with sudo: sudo $0"
    exit 1
fi

# ── Detect interface ──
IFACE=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
if [ -z "$IFACE" ]; then
    IFACE=$(ip -br link | grep -v lo | awk '{print $1}' | head -1)
fi

if [ -z "$IFACE" ]; then
    echo -e "${RED}ERROR:${NC} No network interface found."
    exit 1
fi

# ── Show current config ──
echo ""
echo -e "${BOLD}Current Configuration:${NC}"
echo -e "  Interface: ${GREEN}$IFACE${NC}"
CURRENT_IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep inet | awk '{print $2}' | head -1)
echo -e "  IP/CIDR:   ${GREEN}${CURRENT_IP:-none}${NC}"
CURRENT_GW=$(ip route | grep default | awk '{print $3}' | head -1)
echo -e "  Gateway:   ${GREEN}${CURRENT_GW:-none}${NC}"
echo ""

# ── Get new settings ──
read -p "New IP address (e.g. 10.0.0.10): " NEW_IP
read -p "Subnet CIDR (e.g. 24): " SUBNET
read -p "Gateway (e.g. 10.0.0.1): " GATEWAY

if [ -z "$NEW_IP" ] || [ -z "$SUBNET" ] || [ -z "$GATEWAY" ]; then
    echo -e "${RED}ERROR:${NC} All fields are required."
    exit 1
fi

# ── Detect distro ──
detect_distro() {
    if [ -f /etc/debian_version ]; then
        if command -v netplan > /dev/null 2>&1; then
            echo "ubuntu"
        else
            echo "kali"
        fi
    elif [ -f /etc/redhat-release ]; then
        echo "centos"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)
echo ""
echo -e "Detected OS: ${BOLD}$DISTRO${NC}"
echo -e "Will set: ${BOLD}$IFACE${NC} → ${GREEN}$NEW_IP/$SUBNET${NC} gw ${GREEN}$GATEWAY${NC}"
echo ""

read -p "Apply these settings? (y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy] ]]; then
    echo "Cancelled."
    exit 0
fi

# ── Apply config ──
apply_kali() {
    cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto $IFACE
iface $IFACE inet static
    address $NEW_IP
    netmask $SUBNET
    gateway $GATEWAY
EOF
    systemctl restart networking
}

apply_ubuntu() {
    local netplan_file
    netplan_file=$(ls /etc/netplan/*.yaml 2>/dev/null | head -1)
    if [ -z "$netplan_file" ]; then
        netplan_file="/etc/netplan/01-netcfg.yaml"
    fi

    cat > "$netplan_file" << EOF
network:
  version: 2
  ethernets:
    $IFACE:
      addresses:
        - $NEW_IP/$SUBNET
      gateway4: $GATEWAY
EOF
    netplan apply
}

apply_centos() {
    cat > "/etc/sysconfig/network-scripts/ifcfg-$IFACE" << EOF
TYPE=Ethernet
BOOTPROTO=static
NAME=$IFACE
DEVICE=$IFACE
ONBOOT=yes
IPADDR=$NEW_IP
PREFIX=$SUBNET
GATEWAY=$GATEWAY
EOF
    systemctl restart network
}

apply_temporary() {
    ip addr flush dev "$IFACE"
    ip addr add "$NEW_IP/$SUBNET" dev "$IFACE"
    ip route add default via "$GATEWAY" dev "$IFACE"
}

case "$DISTRO" in
    kali)    apply_kali ;;
    ubuntu)  apply_ubuntu ;;
    centos)  apply_centos ;;
    *)
        echo -e "${YELLOW}Unknown distro — applying temporarily${NC}"
        apply_temporary
        ;;
esac

# ── Verify ──
echo ""
echo -e "${BOLD}New Configuration:${NC}"
NEW_ACTUAL=$(ip -4 addr show "$IFACE" 2>/dev/null | grep inet | awk '{print $2}' | head -1)
echo -e "  Interface: ${GREEN}$IFACE${NC}"
echo -e "  IP/CIDR:   ${GREEN}${NEW_ACTUAL:-failed to detect}${NC}"
echo ""

if ping -c 1 -W 2 "$GATEWAY" > /dev/null 2>&1; then
    echo -e "${GREEN}✔ Gateway $GATEWAY is reachable!${NC}"
else
    echo -e "${RED}✘ Gateway $GATEWAY is NOT reachable — check your settings.${NC}"
fi
FULLSCRIPT
        chmod +x "$SANDBOX/ip_changer.sh"
        success "Created $SANDBOX/ip_changer.sh"
        echo ""
        info "View it with: ${BOLD}cat $SANDBOX/ip_changer.sh${NC}"
        info "Run it with:  ${BOLD}sudo $SANDBOX/ip_changer.sh${NC}"
    fi
    pause

    # ── 6.4 Concepts Used ──
    section_header "6.4 — Everything We Used"

    info "That one script combined everything from this workshop:"
    echo ""
    echo -e "    ${GREEN}✔${NC}  Shebang line (#!/bin/bash)"
    echo -e "    ${GREEN}✔${NC}  Variables and command substitution"
    echo -e "    ${GREEN}✔${NC}  User input with read"
    echo -e "    ${GREEN}✔${NC}  If/else conditionals"
    echo -e "    ${GREEN}✔${NC}  File tests ([ -f file ])"
    echo -e "    ${GREEN}✔${NC}  Functions with local variables"
    echo -e "    ${GREEN}✔${NC}  Case statement (like a multi-way if/else)"
    echo -e "    ${GREEN}✔${NC}  Root permission check"
    echo -e "    ${GREEN}✔${NC}  set -euo pipefail for safety"
    echo -e "    ${GREEN}✔${NC}  Here documents (cat > file << EOF)"
    echo -e "    ${GREEN}✔${NC}  Exit codes"
    echo -e "    ${GREEN}✔${NC}  Colors for terminal output"
    pause

    # ── Exercise ──
    section_header "Final Exercise: Build Your Own Tool"

    echo -e "  ${BOLD}Choose one:${NC}"
    echo ""
    echo -e "    ${CYAN}A.${NC} ${BOLD}Service Checker${NC}"
    echo "       Write a script that checks if sshd, apache2, and named"
    echo "       are running. Print [UP] or [DOWN] for each. Offer to"
    echo "       start any that are down."
    echo ""
    echo -e "    ${CYAN}B.${NC} ${BOLD}User Auditor${NC}"
    echo "       Write a script that:"
    echo "       - Lists all users with /bin/bash shell"
    echo "       - Checks for UID 0 accounts"
    echo "       - Checks for accounts with empty passwords"
    echo "       - Outputs a report"
    echo ""
    echo -e "    ${CYAN}C.${NC} ${BOLD}Backup Script${NC}"
    echo "       Write a script that:"
    echo "       - Takes a directory as \$1"
    echo "       - Creates a timestamped backup with rsync"
    echo "       - Logs the result"
    echo "       - Set it up with cron to run hourly"
    echo ""

    if ask_yn "Show answer for option A (Service Checker)?"; then
        echo ""
        show_file "service_checker.sh" \
'#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo"; exit 1
fi

services=("sshd" "apache2" "named")

for svc in "${services[@]}"; do
    if systemctl is-active "$svc" > /dev/null 2>&1; then
        echo "[UP]   $svc"
    else
        echo "[DOWN] $svc"
        read -p "  Start $svc? (y/n): " answer
        if [[ "$answer" =~ ^[Yy] ]]; then
            systemctl start "$svc"
            echo "  → Started $svc"
        fi
    fi
done'
    fi
    pause
}

# ── Cheat Sheet ──────────────────────────────────────────────────────────────

cheat_sheet() {
    clear_screen
    section_header "Bash Scripting Quick Reference"

    echo -e "  ${BOLD}${CYAN}── BASICS ──${NC}"
    echo -e "  ${GREEN}#!/bin/bash${NC}                      shebang (first line)"
    echo -e "  ${GREEN}chmod +x script.sh${NC}               make executable"
    echo -e "  ${GREEN}./script.sh${NC}                      run the script"
    echo -e "  ${GREEN}bash script.sh${NC}                   run without chmod"
    echo ""
    echo -e "  ${BOLD}${CYAN}── VARIABLES ──${NC}"
    echo -e "  ${GREEN}name=\"value\"${NC}                     set (no spaces around =)"
    echo -e "  ${GREEN}echo \"\$name\"${NC}                     read"
    echo -e "  ${GREEN}result=\$(command)${NC}                capture command output"
    echo -e "  ${GREEN}\$1 \$2 \$# \$@ \$?${NC}                 positional args, count, all, exit code"
    echo -e "  ${GREEN}read -p \"Prompt: \" var${NC}           user input"
    echo ""
    echo -e "  ${BOLD}${CYAN}── CONDITIONALS ──${NC}"
    echo -e "  ${GREEN}if [ cond ]; then ... fi${NC}         basic if"
    echo -e "  ${GREEN}[ \"\$a\" = \"\$b\" ]${NC}                 string equal"
    echo -e "  ${GREEN}[ \$a -eq \$b ]${NC}                   number equal"
    echo -e "  ${GREEN}[ -f file ]${NC}                      file exists?"
    echo -e "  ${GREEN}[ -d dir ]${NC}                       directory exists?"
    echo -e "  ${GREEN}[ -z \"\$var\" ]${NC}                    variable empty?"
    echo ""
    echo -e "  ${BOLD}${CYAN}── LOOPS ──${NC}"
    echo -e "  ${GREEN}for x in a b c; do ... done${NC}     for loop"
    echo -e "  ${GREEN}for i in {1..10}; do ... done${NC}   number range"
    echo -e "  ${GREEN}while [ cond ]; do ... done${NC}     while loop"
    echo -e "  ${GREEN}while read -r line; do ... done < file${NC}  read file"
    echo ""
    echo -e "  ${BOLD}${CYAN}── FUNCTIONS ──${NC}"
    echo -e "  ${GREEN}name() { commands; }${NC}             define function"
    echo -e "  ${GREEN}local var=\"value\"${NC}                function-scoped variable"
    echo -e "  ${GREEN}name arg1 arg2${NC}                   call function"
    echo ""
    echo -e "  ${BOLD}${CYAN}── SAFETY ──${NC}"
    echo -e "  ${GREEN}set -euo pipefail${NC}                exit on error, unset vars, pipes"
    echo -e "  ${GREEN}[ \"\$EUID\" -eq 0 ]${NC}                check if root"
    echo ""
    echo -e "  ${BOLD}${CYAN}── USEFUL PATTERNS ──${NC}"
    echo -e "  ${GREEN}command > file${NC}                   redirect output (overwrite)"
    echo -e "  ${GREEN}command >> file${NC}                  redirect output (append)"
    echo -e "  ${GREEN}command 2>/dev/null${NC}              hide error messages"
    echo -e "  ${GREEN}command > file 2>&1${NC}              redirect stdout + stderr"
    echo -e "  ${GREEN}cmd1 && cmd2${NC}                     run cmd2 only if cmd1 succeeds"
    echo -e "  ${GREEN}cmd1 || cmd2${NC}                     run cmd2 only if cmd1 fails"

    pause
}

# ── Main Menu ────────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        clear_screen
        banner

        echo -e "  ${BOLD}Modules:${NC}"
        echo ""
        echo -e "    ${CYAN}1${NC}  Hello World — Your First Script"
        echo -e "       ${DIM}Shebang, echo, chmod, comments${NC}"
        echo ""
        echo -e "    ${CYAN}2${NC}  Variables & User Input"
        echo -e "       ${DIM}Assignment, substitution, read, quoting, special vars${NC}"
        echo ""
        echo -e "    ${CYAN}3${NC}  Conditionals & Logic"
        echo -e "       ${DIM}If/else, comparisons, file tests, exit codes${NC}"
        echo ""
        echo -e "    ${CYAN}4${NC}  Loops & Iteration"
        echo -e "       ${DIM}For loops, while loops, reading files, ping sweeps${NC}"
        echo ""
        echo -e "    ${CYAN}5${NC}  Functions & Root Permissions"
        echo -e "       ${DIM}Functions, local vars, root checks, script template${NC}"
        echo ""
        echo -e "    ${CYAN}6${NC}  Capstone — Build an IP Changer"
        echo -e "       ${DIM}Full script combining everything, real-world tool${NC}"
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
            1) module_hello_world ;;
            2) module_variables ;;
            3) module_conditionals ;;
            4) module_loops ;;
            5) module_functions ;;
            6) module_ip_changer ;;
            c|C) cheat_sheet ;;
            a|A)
                module_hello_world
                module_variables
                module_conditionals
                module_loops
                module_functions
                module_ip_changer
                cheat_sheet
                ;;
            q|Q)
                sandbox_cleanup
                echo ""
                echo -e "  ${GREEN}Now go automate everything.${NC}"
                echo ""
                exit 0
                ;;
            *) echo -e "  ${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# ── Entry Point ──────────────────────────────────────────────────────────────

main_menu
