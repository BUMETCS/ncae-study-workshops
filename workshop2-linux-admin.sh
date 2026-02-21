#!/bin/bash
# ============================================================================
#  NCAE Cybersecurity Competition — Intro to Linux Admin Workshop
#  Interactive hands-on training: terminal basics through user management
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SANDBOX="/tmp/linux-workshop"

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
    echo -e "${CYAN}║${NC}${BOLD}          NCAE Intro to Linux Administration                ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${DIM}          Terminal · Files · Users · Permissions             ${NC}${CYAN}║${NC}"
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

show_output() {
    local label="$1"
    shift
    echo -e "  ${DIM}$label:${NC}"
    while IFS= read -r line; do
        echo -e "    ${DIM}$line${NC}"
    done <<< "$@"
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

# ── Module 1: Terminal Basics & Navigation ───────────────────────────────────

module_terminal_basics() {
    clear_screen
    section_header "Module 1: Getting Your Bearings"

    echo -e "  ${BOLD}What is a terminal?${NC}"
    echo ""
    echo -e "  The terminal (also called \"shell\" or \"command line\") is a"
    echo -e "  text-based way to talk to your computer. Instead of clicking"
    echo -e "  icons, you type commands. It looks intimidating at first,"
    echo -e "  but it's actually ${BOLD}faster${NC} and ${BOLD}more powerful${NC} than a GUI"
    echo -e "  once you learn the basics."
    echo ""
    echo -e "  Think of it like texting your computer — you send a command,"
    echo -e "  it sends back a response."
    pause

    # ── 1.1 Who Am I ──
    section_header "1.1 — Who Am I? Where Am I?"

    info "The very first things to figure out on any Linux box:"
    echo ""

    explain "${BOLD}whoami${NC} — prints which user you're logged in as"
    try_it "whoami"

    explain "${BOLD}hostname${NC} — prints the name of the machine you're on"
    try_it "hostname"

    explain "${BOLD}pwd${NC} — \"print working directory\" — shows your current location"
    explain "Think of it as GPS for the filesystem"
    try_it "pwd"

    pause

    # ── 1.2 Looking Around with ls ──
    section_header "1.2 — Looking Around with 'ls'"

    info "${BOLD}ls${NC} lists what's in the current directory (folder)."
    echo ""

    explain "${BOLD}ls${NC} — basic listing (just file/folder names)"
    try_it "ls"

    explain "${BOLD}ls -l${NC} — \"long\" format: shows permissions, owner, size, date"
    try_it "ls -l"

    echo ""
    info "Reading the output of ${BOLD}ls -l${NC}:"
    echo ""
    echo -e "  ${DIM}drwxr-xr-x  2 root root 4096 Jan 15 09:00 Documents${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     │  │    │    │    │             └─ name${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     │  │    │    │    └─ modified date${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     │  │    │    └─ size in bytes${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     │  │    └─ group owner${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     │  └─ user owner${NC}"
    echo -e "  ${DIM}│├┤├┤├┤     └─ number of links${NC}"
    echo -e "  ${DIM}│├┤├┤└┤${NC}"
    echo -e "  ${DIM}│├┤├┤ └─ others' permissions (r/w/x)${NC}"
    echo -e "  ${DIM}│├┤└┤${NC}"
    echo -e "  ${DIM}│├┤ └─ group permissions (r/w/x)${NC}"
    echo -e "  ${DIM}│└┤${NC}"
    echo -e "  ${DIM}│ └─ owner permissions (r/w/x)${NC}"
    echo -e "  ${DIM}└─ type: d=directory, -=file, l=link${NC}"
    pause

    explain "${BOLD}ls -la${NC} — same as -l, but includes hidden files (starting with .)"
    explain "Hidden files are used for config: .bashrc, .ssh, .profile, etc."
    try_it "ls -la"

    explain "${BOLD}ls -lah${NC} — adds \"human-readable\" sizes (K, M, G instead of bytes)"
    try_it "ls -lah"

    pause

    # ── 1.3 Navigation with cd ──
    section_header "1.3 — Navigation with 'cd'"

    info "${BOLD}cd${NC} means \"change directory\" — it moves you around the filesystem."
    echo ""

    explain "${BOLD}cd /tmp${NC} — go to /tmp (absolute path — starts with /)"
    try_it "cd /tmp && pwd"

    explain "${BOLD}cd ..${NC} — go UP one directory (the parent folder)"
    try_it "cd .. && pwd"

    explain "${BOLD}cd ~${NC} — go to your home directory (shortcut for /home/yourusername)"
    try_it "cd ~ && pwd"

    explain "${BOLD}cd /${NC} — go to the root of the filesystem (the very top)"
    try_it "cd / && pwd"

    explain "${BOLD}cd -${NC} — go back to wherever you just were (like an undo)"
    try_it "cd - && pwd"

    pause

    # ── 1.4 The Filesystem Tree ──
    section_header "1.4 — The Linux Filesystem Tree"

    info "Everything in Linux starts from ${BOLD}/${NC} (called \"root\")."
    info "There are no drive letters (C:, D:) like Windows."
    echo ""

    echo -e "  ${BOLD}/${NC} (root — the top of everything)"
    echo -e "  ${DIM}├── ${NC}${BOLD}/home${NC}     ${DIM}← user home directories (/home/bob, /home/alice)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/etc${NC}      ${DIM}← system config files (passwords, network, services)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/var${NC}      ${DIM}← variable data (logs, web files, mail)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/tmp${NC}      ${DIM}← temporary files (anyone can write here, cleared on reboot)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/root${NC}     ${DIM}← root user's home directory (NOT the same as /)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/bin${NC}      ${DIM}← essential commands (ls, cp, mv, cat)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/sbin${NC}     ${DIM}← system admin commands (iptables, fdisk)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/usr${NC}      ${DIM}← user programs and libraries${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/opt${NC}      ${DIM}← optional/third-party software${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/dev${NC}      ${DIM}← device files (hard drives, USB, etc.)${NC}"
    echo -e "  ${DIM}├── ${NC}${BOLD}/proc${NC}     ${DIM}← virtual filesystem (running processes, system info)${NC}"
    echo -e "  ${DIM}└── ${NC}${BOLD}/mnt${NC}      ${DIM}← mount points for external drives${NC}"
    echo ""
    warn "For the competition, you'll mostly live in ${BOLD}/etc${NC}, ${BOLD}/home${NC}, ${BOLD}/var${NC}, and ${BOLD}/tmp${NC}."

    echo ""
    if ask_yn "Run live demo? (explore some of these directories)"; then
        explain "Let's peek at /etc (where config lives):"
        run_command "ls /etc | head -20"
        explain "And /var/log (where logs live):"
        run_command "ls /var/log 2>/dev/null | head -10"
    fi

    # ── 1.5 Tab Completion ──
    section_header "1.5 — Pro Tip: Tab Completion"

    info "The ${BOLD}Tab${NC} key is your best friend in the terminal."
    echo ""
    echo -e "  ${BOLD}How it works:${NC}"
    echo -e "    1. Start typing a command or path"
    echo -e "    2. Press ${BOLD}Tab${NC}"
    echo -e "    3. The shell auto-completes it for you"
    echo ""
    echo -e "  ${BOLD}Examples:${NC}"
    echo -e "    ${GREEN}cd /et${NC}${DIM}<Tab>${NC}  →  ${GREEN}cd /etc/${NC}"
    echo -e "    ${GREEN}ls /home/bo${NC}${DIM}<Tab>${NC}  →  ${GREEN}ls /home/bob/${NC}"
    echo -e "    ${GREEN}systemctl sta${NC}${DIM}<Tab>${NC}  →  ${GREEN}systemctl status${NC}"
    echo ""
    echo -e "  If there are multiple matches, press ${BOLD}Tab twice${NC} to see them all."
    echo ""
    warn "Use Tab constantly — it saves time and prevents typos."
    pause
}

# ── Module 2: Directories & File Paths ───────────────────────────────────────

module_directories() {
    clear_screen
    section_header "Module 2: Directories & File Paths"
    sandbox_setup

    echo -e "  Now that you can navigate around, let's learn to ${BOLD}create${NC},"
    echo -e "  ${BOLD}move${NC}, ${BOLD}copy${NC}, and ${BOLD}remove${NC} directories (folders)."
    pause

    # ── 2.1 Making Directories ──
    section_header "2.1 — Creating Directories with 'mkdir'"

    info "${BOLD}mkdir${NC} = \"make directory\" — creates a new folder."
    echo ""

    explain "${BOLD}mkdir foldername${NC} — creates a single folder"
    try_it "cd /tmp/linux-workshop && mkdir projects && ls"

    echo ""
    explain "${BOLD}mkdir -p${NC} — creates parent directories too (nested folders)"
    explain "Without -p, mkdir fails if the parent doesn't exist"
    try_it "mkdir -p /tmp/linux-workshop/company/engineering/team-alpha && ls -R /tmp/linux-workshop/company"

    echo ""
    info "The ${BOLD}-R${NC} flag on ls means \"recursive\" — it shows everything inside,"
    info "including subfolders and their contents. Very useful for seeing"
    info "the full structure of a directory tree."
    pause

    # ── 2.2 Absolute vs Relative Paths ──
    section_header "2.2 — Absolute vs Relative Paths"

    info "There are two ways to refer to any file or folder:"
    echo ""
    echo -e "  ${BOLD}Absolute path${NC} — starts with / — the FULL path from root"
    echo -e "    Example: ${GREEN}/home/bob/Documents/report.txt${NC}"
    echo -e "    Always works, no matter where you are"
    echo ""
    echo -e "  ${BOLD}Relative path${NC} — starts from wherever you ARE right now"
    echo -e "    Example: ${GREEN}Documents/report.txt${NC} (if you're already in /home/bob)"
    echo -e "    Shorter to type but depends on your current location"
    echo ""
    echo -e "  ${BOLD}Special shortcuts:${NC}"
    echo -e "    ${GREEN}.${NC}   = current directory"
    echo -e "    ${GREEN}..${NC}  = parent directory (one level up)"
    echo -e "    ${GREEN}~${NC}   = your home directory"
    echo ""

    explain "Same file, different ways to reference it:"
    echo -e "    ${GREEN}/tmp/linux-workshop/projects${NC}       ${DIM}← absolute${NC}"
    echo -e "    ${GREEN}./projects${NC}                         ${DIM}← relative (if in /tmp/linux-workshop)${NC}"
    echo -e "    ${GREEN}../linux-workshop/projects${NC}          ${DIM}← relative (if in /tmp)${NC}"
    pause

    # ── 2.3 Moving & Renaming ──
    section_header "2.3 — Moving & Renaming with 'mv'"

    info "${BOLD}mv${NC} does two things: ${BOLD}move${NC} files/folders AND ${BOLD}rename${NC} them."
    info "Think of it as \"this thing goes there\" or \"this thing is now called that.\""
    echo ""

    explain "${BOLD}mv old_name new_name${NC} — rename a file or folder"
    try_it "cd /tmp/linux-workshop && mv projects my-projects && ls"

    explain "${BOLD}mv file destination/${NC} — move a file into another folder"
    try_it "mkdir -p /tmp/linux-workshop/archive && mv my-projects archive/ && ls archive/"

    echo ""
    warn "${BOLD}mv${NC} will silently overwrite if the destination already exists!"
    info "Use ${BOLD}mv -i${NC} (interactive) to get a confirmation prompt first."
    pause

    # ── 2.4 Copying ──
    section_header "2.4 — Copying with 'cp'"

    info "${BOLD}cp${NC} = copy. The original stays, a duplicate is created."
    echo ""

    explain "First, let's create a file to work with:"
    try_it "echo 'Hello from the workshop' > /tmp/linux-workshop/notes.txt && cat /tmp/linux-workshop/notes.txt"

    explain "${BOLD}cp source destination${NC} — copy a file"
    try_it "cp /tmp/linux-workshop/notes.txt /tmp/linux-workshop/notes-backup.txt && ls /tmp/linux-workshop/"

    explain "${BOLD}cp -r${NC} — copy a directory (recursive — includes everything inside)"
    explain "Without -r, cp refuses to copy folders"
    try_it "cp -r /tmp/linux-workshop/archive /tmp/linux-workshop/archive-copy && ls /tmp/linux-workshop/"
    pause

    # ── 2.5 Removing ──
    section_header "2.5 — Removing with 'rm'"

    warn "There is NO recycle bin in Linux. ${BOLD}rm${NC} is permanent. Gone forever."
    echo ""

    explain "${BOLD}rm file${NC} — delete a file"
    try_it "rm /tmp/linux-workshop/notes-backup.txt && ls /tmp/linux-workshop/"

    explain "${BOLD}rm -r directory${NC} — delete a directory and everything inside it"
    try_it "rm -r /tmp/linux-workshop/archive-copy && ls /tmp/linux-workshop/"

    explain "${BOLD}rmdir directory${NC} — only deletes EMPTY directories (safer)"
    try_it "mkdir /tmp/linux-workshop/empty-folder && rmdir /tmp/linux-workshop/empty-folder && ls /tmp/linux-workshop/"

    echo ""
    warn "${RED}NEVER run:${NC}  ${RED}rm -rf /${NC}  — this deletes your entire system."
    warn "The ${BOLD}-f${NC} flag means \"force\" — no confirmation, no mercy."
    info "Always double-check your path before pressing Enter with rm."
    pause

    # ── 2.6 History ──
    section_header "2.6 — Command History"

    info "The shell remembers every command you've typed."
    echo ""
    explain "${BOLD}history${NC} — shows all previous commands with line numbers"
    try_it "history | tail -15"

    echo ""
    info "Shortcuts for reusing old commands:"
    echo -e "    ${GREEN}↑ / ↓${NC}       ${DIM}← arrow keys scroll through previous commands${NC}"
    echo -e "    ${GREEN}!!${NC}          ${DIM}← repeat the last command${NC}"
    echo -e "    ${GREEN}!42${NC}         ${DIM}← repeat command #42 from history${NC}"
    echo -e "    ${GREEN}Ctrl+R${NC}      ${DIM}← search history (start typing to find a command)${NC}"
    echo ""

    warn "Super useful trick: forgot sudo? Type ${BOLD}sudo !!${NC}"
    echo -e "    ${DIM}Example: you type${NC} ${GREEN}apt update${NC} ${DIM}and get \"Permission denied\"${NC}"
    echo -e "    ${DIM}Then type${NC} ${GREEN}sudo !!${NC} ${DIM}which expands to${NC} ${GREEN}sudo apt update${NC}"
    pause

    # ── Exercise ──
    section_header "Exercise: Directory Drill"

    echo -e "  ${BOLD}Tasks:${NC} (try these yourself!)"
    echo ""
    echo "    1. Create this folder structure:"
    echo -e "       ${GREEN}/tmp/linux-workshop/exercise/logs/${NC}"
    echo -e "       ${GREEN}/tmp/linux-workshop/exercise/config/${NC}"
    echo -e "       ${GREEN}/tmp/linux-workshop/exercise/backups/${NC}"
    echo ""
    echo "    2. Navigate into the exercise/ folder"
    echo "    3. Rename 'logs' to 'app-logs'"
    echo "    4. Copy 'config' to 'config-backup'"
    echo "    5. Remove 'backups'"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "mkdir -p /tmp/linux-workshop/exercise/{logs,config,backups}"
        show_command "cd /tmp/linux-workshop/exercise"
        show_command "mv logs app-logs"
        show_command "cp -r config config-backup"
        show_command "rm -r backups"
        echo ""
        success "Bonus: the ${BOLD}{a,b,c}${NC} syntax creates multiple dirs at once!"

        if ask_yn "Run the answer?"; then
            run_command "mkdir -p /tmp/linux-workshop/exercise/{logs,config,backups} && cd /tmp/linux-workshop/exercise && mv logs app-logs && cp -r config config-backup && rm -r backups && ls"
        fi
    fi
    pause
}

# ── Module 3: Files — Create, Read, Edit ─────────────────────────────────────

module_files() {
    clear_screen
    section_header "Module 3: Creating, Reading & Editing Files"
    sandbox_setup

    echo -e "  Files are everything in Linux. Config files, logs, scripts,"
    echo -e "  passwords — they're all just text files. Let's learn to"
    echo -e "  create them, read them, and edit them."
    pause

    # ── 3.1 Creating Files ──
    section_header "3.1 — Creating Files"

    info "${BOLD}touch${NC} — creates an empty file (or updates the timestamp if it exists)"
    try_it "touch /tmp/linux-workshop/myfile.txt && ls -l /tmp/linux-workshop/myfile.txt"

    echo ""
    info "${BOLD}echo${NC} — prints text. Combine with ${BOLD}>${NC} to write to a file:"
    echo ""
    explain "${BOLD}echo 'text' > file${NC}  — write to file (${RED}overwrites!${NC})"
    try_it "echo 'This is line 1' > /tmp/linux-workshop/myfile.txt && cat /tmp/linux-workshop/myfile.txt"

    explain "${BOLD}echo 'text' >> file${NC} — append to file (adds to the end)"
    try_it "echo 'This is line 2' >> /tmp/linux-workshop/myfile.txt && cat /tmp/linux-workshop/myfile.txt"

    echo ""
    warn "${BOLD}>${NC} (one arrow) = overwrite the whole file"
    warn "${BOLD}>>${NC} (two arrows) = add to the end"
    warn "Mixing these up is a very common mistake that deletes data!"
    pause

    # ── 3.2 Reading Files ──
    section_header "3.2 — Reading Files"

    explain "Let's create a bigger file to work with:"
    run_command "for i in \$(seq 1 25); do echo \"Line \$i: This is sample data for our workshop\"; done > /tmp/linux-workshop/bigfile.txt"
    echo ""

    info "${BOLD}cat${NC} — dumps the entire file to screen (short for \"concatenate\")"
    explain "Great for small files. Overwhelming for big ones."
    try_it "cat /tmp/linux-workshop/myfile.txt"

    info "${BOLD}head${NC} — shows the first 10 lines (or -n to pick how many)"
    try_it "head -5 /tmp/linux-workshop/bigfile.txt"

    info "${BOLD}tail${NC} — shows the last 10 lines (great for checking log files)"
    try_it "tail -5 /tmp/linux-workshop/bigfile.txt"

    echo ""
    info "${BOLD}tail -f${NC} — \"follow\" mode: live-updates as new lines are added"
    echo -e "    ${DIM}Super useful for watching log files in real time${NC}"
    echo -e "    ${DIM}Press Ctrl+C to stop following${NC}"
    pause

    info "${BOLD}wc${NC} — \"word count\" — counts lines, words, and characters"
    try_it "wc /tmp/linux-workshop/bigfile.txt"
    echo ""
    explain "Output is: ${BOLD}lines  words  characters  filename${NC}"
    explain "${BOLD}wc -l${NC} — just line count (used constantly with pipes)"
    try_it "wc -l /tmp/linux-workshop/bigfile.txt"
    pause

    # ── 3.3 Editing with Nano ──
    section_header "3.3 — Editing with Nano (Beginner-Friendly)"

    info "${BOLD}nano${NC} is the easiest command-line text editor."
    info "If you've never used a terminal editor, start here."
    echo ""
    show_command "nano /tmp/linux-workshop/myfile.txt"
    echo ""
    echo -e "  ${DIM}┌──────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${DIM}│${NC}  GNU nano 6.2    /tmp/linux-workshop/myfile.txt      ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}                                                      ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  This is line 1                                      ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  This is line 2                                      ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${DIM}(you type here just like notepad)${NC}                   ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}                                                      ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${DIM}^O Write Out   ^X Exit   ^K Cut   ^U Paste${NC}         ${DIM}│${NC}"
    echo -e "  ${DIM}└──────────────────────────────────────────────────────┘${NC}"
    echo ""
    info "Essential nano shortcuts (^ means Ctrl):"
    echo ""
    echo -e "    ${GREEN}Ctrl+O${NC}  → Save (\"Write Out\") — then press Enter to confirm"
    echo -e "    ${GREEN}Ctrl+X${NC}  → Exit nano"
    echo -e "    ${GREEN}Ctrl+K${NC}  → Cut the current line"
    echo -e "    ${GREEN}Ctrl+U${NC}  → Paste (\"Uncut\")"
    echo -e "    ${GREEN}Ctrl+W${NC}  → Search for text"
    echo -e "    ${GREEN}Ctrl+G${NC}  → Help"
    echo ""
    info "The menu at the bottom always shows you what keys do what."
    pause

    # ── 3.4 Editing with Vi/Vim ──
    section_header "3.4 — Editing with Vi/Vim (Powerful but Tricky)"

    info "${BOLD}vi${NC} (or ${BOLD}vim${NC}) is installed on virtually every Linux system."
    info "It's the editor you'll always have available — worth learning."
    echo ""
    warn "Vi has ${BOLD}modes${NC}. This is what confuses everyone at first."
    echo ""
    echo -e "  ${BOLD}The Two Modes You Need to Know:${NC}"
    echo ""
    echo -e "    ${CYAN}NORMAL mode${NC} (default when you open vi)"
    echo -e "      → You're in \"command\" mode. Typing letters = commands,"
    echo -e "        NOT typing text. Pressing 'dd' deletes a line, etc."
    echo ""
    echo -e "    ${CYAN}INSERT mode${NC} (press ${BOLD}i${NC} to enter)"
    echo -e "      → Now you can type text normally, like notepad."
    echo -e "      → Press ${BOLD}Esc${NC} to go back to NORMAL mode."
    echo ""
    echo -e "  ${BOLD}The Survival Commands:${NC}"
    echo ""
    echo -e "    ${GREEN}i${NC}        → Enter INSERT mode (start typing)"
    echo -e "    ${GREEN}Esc${NC}      → Back to NORMAL mode"
    echo -e "    ${GREEN}:w${NC}       → Save (\"write\")"
    echo -e "    ${GREEN}:q${NC}       → Quit"
    echo -e "    ${GREEN}:wq${NC}      → Save AND quit (most common)"
    echo -e "    ${GREEN}:q!${NC}      → Quit WITHOUT saving (the ! means \"force\")"
    echo -e "    ${GREEN}dd${NC}       → Delete current line (in NORMAL mode)"
    echo -e "    ${GREEN}u${NC}        → Undo"
    echo ""
    show_command "vi /tmp/linux-workshop/myfile.txt"
    echo ""
    warn "If you're stuck in vi: press ${BOLD}Esc${NC}, then type ${BOLD}:q!${NC} and Enter."
    warn "That's the \"get me out of here\" sequence."
    pause

    # ── 3.5 Deleting Files ──
    section_header "3.5 — Deleting Files"

    info "You already learned ${BOLD}rm${NC} for directories. Same for files:"
    echo ""
    show_command "rm filename.txt"
    echo ""
    info "${BOLD}rm -i${NC} — asks for confirmation before deleting (safer)"
    info "Some people add ${BOLD}alias rm='rm -i'${NC} to their .bashrc for safety."
    echo ""

    explain "Let's clean up our test files:"
    try_it "rm /tmp/linux-workshop/myfile.txt && ls /tmp/linux-workshop/"

    pause

    # ── Exercise ──
    section_header "Exercise: File Operations"

    echo -e "  ${BOLD}Tasks:${NC}"
    echo ""
    echo "    1. Create a file called /tmp/linux-workshop/server-info.txt"
    echo "    2. Write your hostname into it (hint: use a command + >)"
    echo "    3. Append your username to the file (hint: >> )"
    echo "    4. Append today's date (hint: the 'date' command)"
    echo "    5. Read the file to verify"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "hostname > /tmp/linux-workshop/server-info.txt"
        show_command "whoami >> /tmp/linux-workshop/server-info.txt"
        show_command "date >> /tmp/linux-workshop/server-info.txt"
        show_command "cat /tmp/linux-workshop/server-info.txt"

        if ask_yn "Run the answer?"; then
            run_command "hostname > /tmp/linux-workshop/server-info.txt && whoami >> /tmp/linux-workshop/server-info.txt && date >> /tmp/linux-workshop/server-info.txt && cat /tmp/linux-workshop/server-info.txt"
        fi
    fi
    pause
}

# ── Module 4: Users & Permissions ────────────────────────────────────────────

module_users_permissions() {
    clear_screen
    section_header "Module 4: Users & Permissions"

    echo -e "  Linux is a ${BOLD}multi-user${NC} system. Every file has an owner,"
    echo -e "  and every action is done as a specific user. Understanding"
    echo -e "  users and permissions is ${BOLD}critical${NC} for the competition."
    pause

    # ── 4.1 User Accounts ──
    section_header "4.1 — Creating User Accounts"

    info "Two ways to create users:"
    echo ""
    explain "${BOLD}useradd${NC} — bare-bones, doesn't create home dir by default"
    show_command "sudo useradd bob"
    echo ""
    explain "${BOLD}adduser${NC} — friendlier, asks questions, creates home dir"
    show_command "sudo adduser bob"
    echo ""
    info "The difference (this trips people up):"
    echo ""
    echo -e "    ${BOLD}useradd${NC}  → minimal. Need ${BOLD}-m${NC} flag to create home dir"
    echo -e "              ${GREEN}sudo useradd -m bob${NC}"
    echo ""
    echo -e "    ${BOLD}adduser${NC} → interactive. Creates home dir, asks for password"
    echo -e "              ${GREEN}sudo adduser bob${NC}"
    echo ""
    warn "On ${BOLD}CentOS/RHEL${NC}: adduser is just a symlink to useradd"
    warn "On ${BOLD}Debian/Ubuntu/Kali${NC}: adduser is a separate, friendlier script"
    pause

    # ── 4.2 Setting Passwords ──
    section_header "4.2 — Setting Passwords"

    info "${BOLD}passwd${NC} — set or change a user's password"
    echo ""
    show_command "sudo passwd bob"
    echo -e "    ${DIM}Enter new UNIX password: ********${NC}"
    echo -e "    ${DIM}Retype new UNIX password: ********${NC}"
    echo ""
    info "Change your own password (no sudo needed):"
    show_command "passwd"
    echo ""
    info "Force user to change password at next login:"
    show_command "sudo passwd -e bob"
    pause

    # ── 4.3 Switching Users ──
    section_header "4.3 — Switching Users & Checking Identity"

    info "${BOLD}su${NC} = \"switch user\" — become another user"
    echo ""
    show_command "su bob"
    echo -e "    ${DIM}(prompts for bob's password, opens a shell as bob)${NC}"
    echo ""
    show_command "su - bob"
    echo -e "    ${DIM}(the dash loads bob's full environment — .bashrc, PATH, etc.)${NC}"
    echo -e "    ${DIM}(without the dash, you keep YOUR environment)${NC}"
    echo ""
    info "${BOLD}exit${NC} — go back to your previous user"
    echo ""
    info "${BOLD}id${NC} — shows your user ID (uid), group ID (gid), and all groups"
    try_it "id"
    pause

    # ── 4.4 File Permissions ──
    section_header "4.4 — File Permissions Explained"

    info "Every file and directory has three sets of permissions:"
    echo ""
    echo -e "    ${BOLD}Owner${NC}  — the user who owns the file"
    echo -e "    ${BOLD}Group${NC}  — the group assigned to the file"
    echo -e "    ${BOLD}Others${NC} — everyone else"
    echo ""
    info "Each set has three permission types:"
    echo ""
    echo -e "    ${BOLD}r${NC} (read)    = can see the contents     ${DIM}(value: 4)${NC}"
    echo -e "    ${BOLD}w${NC} (write)   = can modify the contents  ${DIM}(value: 2)${NC}"
    echo -e "    ${BOLD}x${NC} (execute) = can run it as a program  ${DIM}(value: 1)${NC}"
    echo ""

    info "Example:"
    echo -e "    ${GREEN}-rwxr-xr--${NC}  1 bob  staff  1024  Jan 15 09:00  script.sh"
    echo ""
    echo -e "    ${BOLD}rwx${NC} = owner (bob)  → read + write + execute  ${DIM}= 4+2+1 = 7${NC}"
    echo -e "    ${BOLD}r-x${NC} = group (staff) → read + execute         ${DIM}= 4+0+1 = 5${NC}"
    echo -e "    ${BOLD}r--${NC} = others       → read only               ${DIM}= 4+0+0 = 4${NC}"
    echo ""
    echo -e "    So this file's numeric permissions are: ${BOLD}754${NC}"
    pause

    # ── 4.5 chmod ──
    section_header "4.5 — Changing Permissions with 'chmod'"

    info "${BOLD}chmod${NC} = \"change mode\" — modifies file permissions"
    echo ""
    info "Two syntaxes — numeric is faster, symbolic is more readable:"
    echo ""
    echo -e "  ${BOLD}Numeric (octal):${NC}"
    show_command "chmod 755 script.sh"
    echo -e "    ${DIM}owner=rwx(7), group=r-x(5), others=r-x(5)${NC}"
    echo ""
    show_command "chmod 644 config.txt"
    echo -e "    ${DIM}owner=rw-(6), group=r--(4), others=r--(4)${NC}"
    echo ""

    echo -e "  ${BOLD}Common permission numbers:${NC}"
    echo -e "    ${GREEN}777${NC} — everyone can do everything  ${RED}(dangerous!)${NC}"
    echo -e "    ${GREEN}755${NC} — owner: full, others: read+execute ${DIM}(scripts, dirs)${NC}"
    echo -e "    ${GREEN}644${NC} — owner: read+write, others: read ${DIM}(config files)${NC}"
    echo -e "    ${GREEN}600${NC} — owner only, nobody else ${DIM}(private keys, passwords)${NC}"
    echo -e "    ${GREEN}700${NC} — owner only, full access ${DIM}(private directories)${NC}"
    echo ""

    echo -e "  ${BOLD}Symbolic:${NC}"
    show_command "chmod u+x script.sh"
    echo -e "    ${DIM}u=user/owner, g=group, o=others, a=all${NC}"
    echo -e "    ${DIM}+=add, -=remove, ==set exactly${NC}"
    echo ""
    show_command "chmod go-w config.txt"
    echo -e "    ${DIM}Remove write permission from group and others${NC}"
    pause

    sandbox_setup
    explain "Let's see this in action:"
    run_command "touch /tmp/linux-workshop/secret.txt && echo 'password123' > /tmp/linux-workshop/secret.txt"
    try_it "ls -l /tmp/linux-workshop/secret.txt"
    try_it "chmod 600 /tmp/linux-workshop/secret.txt && ls -l /tmp/linux-workshop/secret.txt"
    echo ""
    success "Now only the owner can read or write that file."
    pause

    # ── 4.6 chown ──
    section_header "4.6 — Changing Ownership with 'chown'"

    info "${BOLD}chown${NC} = \"change owner\" — changes who owns a file"
    echo ""
    show_command "sudo chown bob secret.txt"
    echo -e "    ${DIM}Changes the user owner to bob${NC}"
    echo ""
    show_command "sudo chown bob:staff secret.txt"
    echo -e "    ${DIM}Changes user owner to bob AND group to staff${NC}"
    echo ""
    show_command "sudo chown -R bob:staff /home/bob/"
    echo -e "    ${DIM}-R = recursive — changes ownership of everything inside${NC}"
    echo ""
    warn "Only root (sudo) can change file ownership."
    pause

    # ── 4.7 sudo ──
    section_header "4.7 — Sudo & the Sudoers File"

    info "${BOLD}sudo${NC} = \"superuser do\" — run a command as root (admin)."
    echo ""
    explain "Normal users can't install software, create users, change"
    explain "network config, or modify system files. ${BOLD}sudo${NC} gives"
    explain "temporary root powers for a single command."
    echo ""
    show_command "sudo apt update"
    echo -e "    ${DIM}Runs 'apt update' with root privileges${NC}"
    echo ""
    info "Who is allowed to use sudo? That's controlled by:"
    echo -e "    ${GREEN}/etc/sudoers${NC}  ← the config file"
    echo ""
    warn "NEVER edit /etc/sudoers directly with nano or vi!"
    warn "Always use ${BOLD}visudo${NC} — it validates the syntax before saving."
    warn "A broken sudoers file can lock you out of root access."
    echo ""
    show_command "sudo visudo"
    echo ""
    info "Typical sudoers line:"
    echo -e "    ${GREEN}bob  ALL=(ALL:ALL) ALL${NC}"
    echo -e "    ${DIM}│     │    │   │    └─ can run: all commands${NC}"
    echo -e "    ${DIM}│     │    │   └─ as any group${NC}"
    echo -e "    ${DIM}│     │    └─ as any user${NC}"
    echo -e "    ${DIM}│     └─ on: all hosts${NC}"
    echo -e "    ${DIM}└─ user: bob${NC}"
    echo ""
    info "Easier way — add user to the sudo group:"
    show_command "sudo usermod -aG sudo bob"
    echo -e "    ${DIM}On CentOS/RHEL, the group is called 'wheel' instead of 'sudo'${NC}"
    pause

    # ── 4.8 Removing Users ──
    section_header "4.8 — Removing Users"

    info "${BOLD}userdel${NC} — delete a user account"
    echo ""
    show_command "sudo userdel bob"
    echo -e "    ${DIM}Removes the account but leaves /home/bob behind${NC}"
    echo ""
    show_command "sudo userdel -r bob"
    echo -e "    ${DIM}-r = remove home directory and mail spool too${NC}"
    echo ""
    warn "In the competition, you might need to remove unauthorized users."
    warn "Always check ${BOLD}/etc/passwd${NC} for unexpected accounts."
    pause

    # ── Exercise ──
    section_header "Exercise: User & Permission Drill"

    echo -e "  ${BOLD}Scenario:${NC} You're the sysadmin. Set up a new developer."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. Create a user called 'developer' with a home directory"
    echo "    2. Set their password"
    echo "    3. Give them sudo access"
    echo "    4. Create /opt/app/ owned by developer"
    echo "    5. Make /opt/app/config.txt readable only by developer"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "sudo useradd -m developer"
        show_command "sudo passwd developer"
        show_command "sudo usermod -aG sudo developer"
        show_command "sudo mkdir -p /opt/app"
        show_command "sudo chown developer:developer /opt/app"
        show_command "sudo touch /opt/app/config.txt"
        show_command "sudo chown developer:developer /opt/app/config.txt"
        show_command "sudo chmod 600 /opt/app/config.txt"
    fi
    pause
}

# ── Module 5: Groups & Password Files ────────────────────────────────────────

module_groups_passwords() {
    clear_screen
    section_header "Module 5: Groups & Password Files"

    echo -e "  Groups let you manage permissions for multiple users at once."
    echo -e "  And the password/shadow files are where Linux stores all"
    echo -e "  the account information. Let's dig in."
    pause

    # ── 5.1 Groups ──
    section_header "5.1 — Managing Groups"

    info "A group is a collection of users. Files can be owned by a group,"
    info "so everyone in that group gets the group's permissions."
    echo ""

    explain "${BOLD}groupadd${NC} — create a new group"
    show_command "sudo groupadd developers"
    echo ""

    explain "${BOLD}usermod -aG${NC} — add a user to a group"
    show_command "sudo usermod -aG developers bob"
    echo -e "    ${DIM}-a = append (DON'T forget this! Without -a, it REPLACES all groups)${NC}"
    echo -e "    ${DIM}-G = supplementary groups${NC}"
    echo ""
    warn "Without the ${BOLD}-a${NC} flag, usermod removes the user from ALL other groups!"
    warn "This is one of the most common and dangerous mistakes."
    echo ""

    explain "${BOLD}groups${NC} — see what groups a user belongs to"
    try_it "groups"

    echo ""
    info "The groups file:"
    show_command "cat /etc/group"
    echo ""
    explain "Format: ${BOLD}groupname:password:GID:members${NC}"
    echo -e "    ${DIM}developers:x:1002:bob,alice${NC}"
    echo -e "    ${DIM}    │       │  │    └─ members of this group${NC}"
    echo -e "    ${DIM}    │       │  └─ group ID number${NC}"
    echo -e "    ${DIM}    │       └─ password placeholder (always x)${NC}"
    echo -e "    ${DIM}    └─ group name${NC}"

    try_it "cat /etc/group | tail -10"
    pause

    explain "${BOLD}groupdel${NC} — delete a group"
    show_command "sudo groupdel developers"
    echo ""
    explain "${BOLD}gpasswd -d${NC} — remove a user from a group"
    show_command "sudo gpasswd -d bob developers"
    pause

    # ── 5.2 /etc/passwd ──
    section_header "5.2 — /etc/passwd (User Database)"

    info "${BOLD}/etc/passwd${NC} lists every user account on the system."
    info "Despite the name, it does NOT contain actual passwords anymore."
    echo ""
    try_it "head -5 /etc/passwd"

    echo ""
    explain "Format (colon-separated):"
    echo ""
    echo -e "    ${GREEN}bob:x:1001:1001:Bob Smith:/home/bob:/bin/bash${NC}"
    echo -e "    ${DIM} │   │  │    │      │         │          └─ login shell${NC}"
    echo -e "    ${DIM} │   │  │    │      │         └─ home directory${NC}"
    echo -e "    ${DIM} │   │  │    │      └─ full name / comment${NC}"
    echo -e "    ${DIM} │   │  │    └─ primary group ID${NC}"
    echo -e "    ${DIM} │   │  └─ user ID (UID)${NC}"
    echo -e "    ${DIM} │   └─ password placeholder (x = in /etc/shadow)${NC}"
    echo -e "    ${DIM} └─ username${NC}"
    echo ""
    info "Important UIDs:"
    echo -e "    ${BOLD}0${NC}          = root (superuser)"
    echo -e "    ${BOLD}1-999${NC}      = system/service accounts"
    echo -e "    ${BOLD}1000+${NC}      = normal human users"
    echo ""
    warn "In competition: check for unauthorized accounts or UID 0 accounts!"
    show_command "grep ':0:' /etc/passwd"
    echo -e "    ${DIM}Any account with UID 0 has root-level access${NC}"
    pause

    # ── 5.3 /etc/shadow ──
    section_header "5.3 — /etc/shadow (Password Hashes)"

    info "${BOLD}/etc/shadow${NC} is where the actual password hashes live."
    info "Only root can read it (that's the whole point of having it)."
    echo ""
    show_command "sudo cat /etc/shadow | head -5"
    echo ""
    explain "Format:"
    echo ""
    echo -e "    ${GREEN}bob:\$6\$salt\$hash:19000:0:99999:7:::${NC}"
    echo -e "    ${DIM} │      │        │    │   │    │${NC}"
    echo -e "    ${DIM} │      │        │    │   │    └─ warning/inactive/expire days${NC}"
    echo -e "    ${DIM} │      │        │    │   └─ max days between password changes${NC}"
    echo -e "    ${DIM} │      │        │    └─ min days between password changes${NC}"
    echo -e "    ${DIM} │      │        └─ days since epoch when password last changed${NC}"
    echo -e "    ${DIM} │      └─ the password hash${NC}"
    echo -e "    ${DIM} └─ username${NC}"
    echo ""
    info "Hash prefixes tell you the algorithm:"
    echo -e "    ${BOLD}\$1\$${NC}   = MD5        ${RED}(weak, crackable)${NC}"
    echo -e "    ${BOLD}\$5\$${NC}   = SHA-256    ${YELLOW}(okay)${NC}"
    echo -e "    ${BOLD}\$6\$${NC}   = SHA-512    ${GREEN}(strong, most common)${NC}"
    echo -e "    ${BOLD}\$y\$${NC}   = yescrypt   ${GREEN}(modern, very strong)${NC}"
    echo ""
    warn "If you see ${BOLD}\$1\$${NC} hashes, the passwords are easy to crack."
    warn "In competition: check what hash algorithm your system uses."
    pause

    info "Special values in the password field:"
    echo ""
    echo -e "    ${BOLD}!${NC} or ${BOLD}*${NC}   = account is locked / no password login"
    echo -e "    ${BOLD}!!${NC}        = password has never been set"
    echo -e "    ${DIM}(empty)${NC}   = no password required ${RED}(very dangerous!)${NC}"
    echo ""
    warn "Lock an account (disable password login):"
    show_command "sudo passwd -l bob"
    info "Unlock it:"
    show_command "sudo passwd -u bob"
    pause

    # ── Exercise ──
    section_header "Exercise: Account Forensics"

    echo -e "  ${BOLD}Scenario:${NC} You suspect someone added a backdoor account."
    echo ""
    echo -e "  ${CYAN}Tasks:${NC}"
    echo "    1. List all users with UID 0 (root-level access)"
    echo "    2. Find any accounts with empty passwords in /etc/shadow"
    echo "    3. List all users with /bin/bash as their shell"
    echo "       (service accounts usually have /sbin/nologin)"
    echo ""

    if ask_yn "Show answer?"; then
        echo ""
        show_command "grep ':0:' /etc/passwd"
        echo -e "    ${DIM}Only 'root' should appear here${NC}"
        echo ""
        show_command "sudo awk -F: '(\$2 == \"\") {print \$1}' /etc/shadow"
        echo -e "    ${DIM}Any output = accounts with no password (bad!)${NC}"
        echo ""
        show_command "grep '/bin/bash' /etc/passwd"
        echo -e "    ${DIM}Check for any usernames you don't recognize${NC}"

        if ask_yn "Run these checks now?"; then
            explain "Users with UID 0:"
            run_command "grep ':0:' /etc/passwd"
            explain "Users with bash shell:"
            run_command "grep '/bin/bash\|/bin/sh' /etc/passwd"
        fi
    fi
    pause
}

# ── Module 6: Text Processing — less, grep, pipes ───────────────────────────

module_text_processing() {
    clear_screen
    section_header "Module 6: Text Processing"
    sandbox_setup

    echo -e "  The real power of Linux comes from chaining simple commands"
    echo -e "  together. This module covers the tools you'll use ${BOLD}constantly${NC}:"
    echo -e "  ${BOLD}less${NC}, ${BOLD}grep${NC}, and ${BOLD}pipes${NC}."
    pause

    # build a sample log file
    run_command "cat > /tmp/linux-workshop/access.log << 'LOGEOF'
192.168.1.10 - - [15/Jan/2025:09:15:22] \"GET /index.html HTTP/1.1\" 200 1024
192.168.1.15 - - [15/Jan/2025:09:15:45] \"GET /login HTTP/1.1\" 200 2048
10.0.0.50 - - [15/Jan/2025:09:16:01] \"POST /login HTTP/1.1\" 401 512
192.168.1.10 - - [15/Jan/2025:09:16:30] \"GET /dashboard HTTP/1.1\" 200 4096
10.0.0.50 - - [15/Jan/2025:09:17:02] \"POST /login HTTP/1.1\" 401 512
10.0.0.50 - - [15/Jan/2025:09:17:45] \"POST /login HTTP/1.1\" 401 512
192.168.1.15 - - [15/Jan/2025:09:18:00] \"GET /api/users HTTP/1.1\" 403 256
10.0.0.50 - - [15/Jan/2025:09:18:30] \"POST /login HTTP/1.1\" 200 2048
10.0.0.50 - - [15/Jan/2025:09:19:00] \"GET /admin HTTP/1.1\" 200 8192
192.168.1.10 - - [15/Jan/2025:09:20:00] \"GET /index.html HTTP/1.1\" 200 1024
10.0.0.50 - - [15/Jan/2025:09:21:00] \"POST /admin/users HTTP/1.1\" 200 512
10.0.0.50 - - [15/Jan/2025:09:22:00] \"DELETE /admin/users/3 HTTP/1.1\" 200 128
LOGEOF"

    success "Created sample log at /tmp/linux-workshop/access.log"
    pause

    # ── 6.1 less ──
    section_header "6.1 — Browsing with 'less'"

    info "${BOLD}less${NC} lets you scroll through a file page by page."
    info "Unlike cat, it doesn't dump everything at once."
    echo ""
    show_command "less /tmp/linux-workshop/access.log"
    echo ""
    info "Navigation inside less:"
    echo ""
    echo -e "    ${GREEN}Space / PgDn${NC}  → next page"
    echo -e "    ${GREEN}b / PgUp${NC}      → previous page"
    echo -e "    ${GREEN}↑ / ↓${NC}         → one line at a time"
    echo -e "    ${GREEN}g${NC}             → go to beginning"
    echo -e "    ${GREEN}G${NC}             → go to end"
    echo -e "    ${GREEN}/pattern${NC}      → search forward for \"pattern\""
    echo -e "    ${GREEN}?pattern${NC}      → search backward"
    echo -e "    ${GREEN}n${NC}             → next search match"
    echo -e "    ${GREEN}N${NC}             → previous search match"
    echo -e "    ${GREEN}q${NC}             → quit"
    echo ""
    info "Pro tip: ${BOLD}less +F${NC} works like ${BOLD}tail -f${NC} (live follow mode)"
    info "Press ${BOLD}Ctrl+C${NC} to stop following, ${BOLD}q${NC} to quit."
    pause

    # ── 6.2 grep ──
    section_header "6.2 — Searching with 'grep'"

    info "${BOLD}grep${NC} searches for patterns in text. It's one of the"
    info "most important commands in all of Linux."
    echo ""
    info "Basic syntax: ${BOLD}grep 'pattern' filename${NC}"
    echo ""

    explain "Find all lines containing '401' (failed login attempts):"
    try_it "grep '401' /tmp/linux-workshop/access.log"

    explain "Find all requests from IP 10.0.0.50:"
    try_it "grep '10.0.0.50' /tmp/linux-workshop/access.log"

    echo ""
    info "Useful grep flags:"
    echo ""
    echo -e "    ${GREEN}-i${NC}   case-insensitive  ${DIM}(grep -i 'error' file)${NC}"
    echo -e "    ${GREEN}-n${NC}   show line numbers  ${DIM}(grep -n 'error' file)${NC}"
    echo -e "    ${GREEN}-c${NC}   count matches only ${DIM}(grep -c 'error' file)${NC}"
    echo -e "    ${GREEN}-v${NC}   invert — show lines that DON'T match"
    echo -e "    ${GREEN}-r${NC}   recursive — search all files in a directory"
    echo -e "    ${GREEN}-l${NC}   just show filenames that contain the match"
    echo ""

    explain "${BOLD}-c${NC} to count how many failed logins:"
    try_it "grep -c '401' /tmp/linux-workshop/access.log"

    explain "${BOLD}-v${NC} to see everything EXCEPT 200 (OK) responses:"
    try_it "grep -v '200' /tmp/linux-workshop/access.log"

    explain "${BOLD}-n${NC} to get line numbers:"
    try_it "grep -n 'admin' /tmp/linux-workshop/access.log"

    pause

    explain "${BOLD}-r${NC} to recursively search a directory:"
    echo -e "    ${GREEN}grep -r 'password' /etc/${NC}"
    echo -e "    ${DIM}Search every file in /etc for the word 'password'${NC}"
    echo ""
    explain "${BOLD}-rl${NC} to just list filenames that match:"
    echo -e "    ${GREEN}grep -rl 'password' /etc/${NC}"
    echo -e "    ${DIM}Shows which files contain 'password' without showing the lines${NC}"
    pause

    # ── 6.3 Pipes ──
    section_header "6.3 — Pipes: Chaining Commands Together"

    info "The ${BOLD}|${NC} (pipe) takes the output of one command and sends"
    info "it as input to the next command. This is where Linux gets powerful."
    echo ""
    echo -e "  ${BOLD}command1 | command2 | command3${NC}"
    echo -e "  ${DIM}output of command1 → input of command2 → input of command3${NC}"
    echo ""

    explain "Count how many times 10.0.0.50 appears in the log:"
    try_it "grep '10.0.0.50' /tmp/linux-workshop/access.log | wc -l"
    echo ""
    explain "Translation: find lines with '10.0.0.50', then count them"
    pause

    explain "Show log entries, sorted, with unique IPs only:"
    try_it "cat /tmp/linux-workshop/access.log | awk '{print \$1}' | sort | uniq -c | sort -rn"
    echo ""
    explain "What that pipeline does, step by step:"
    echo -e "    ${GREEN}cat file${NC}           → read the file"
    echo -e "    ${GREEN}awk '{print \$1}'${NC}   → extract just the first column (IP addresses)"
    echo -e "    ${GREEN}sort${NC}               → sort the IPs alphabetically"
    echo -e "    ${GREEN}uniq -c${NC}            → count consecutive duplicates"
    echo -e "    ${GREEN}sort -rn${NC}           → sort by count, highest first"
    echo ""
    info "This is a CLASSIC log analysis pipeline. Memorize it."
    pause

    explain "Find suspicious activity — failed logins + admin access from same IP:"
    try_it "grep '10.0.0.50' /tmp/linux-workshop/access.log | grep -E '401|admin'"

    echo ""
    explain "More useful pipe combos:"
    echo ""
    echo -e "    ${GREEN}ps aux | grep apache${NC}        ${DIM}← find running processes${NC}"
    echo -e "    ${GREEN}cat /etc/passwd | wc -l${NC}     ${DIM}← count user accounts${NC}"
    echo -e "    ${GREEN}history | grep ssh${NC}          ${DIM}← find SSH commands you've run${NC}"
    echo -e "    ${GREEN}dmesg | tail -20${NC}            ${DIM}← last 20 kernel messages${NC}"
    echo -e "    ${GREEN}ls -la | grep '^d'${NC}          ${DIM}← list only directories${NC}"
    pause

    # ── Exercise ──
    section_header "Exercise: Log Analysis Challenge"

    echo -e "  ${BOLD}Scenario:${NC} Using /tmp/linux-workshop/access.log, answer:"
    echo ""
    echo "    1. How many total requests are in the log?"
    echo "    2. How many requests resulted in 401 (unauthorized)?"
    echo "    3. Which IP made the most requests?"
    echo "    4. Did anyone access /admin? Who?"
    echo "    5. How many unique IPs are in the log?"
    echo ""

    if ask_yn "Show answers?"; then
        echo ""
        explain "1. Total requests:"
        run_command "wc -l /tmp/linux-workshop/access.log"

        explain "2. Failed auth (401):"
        run_command "grep -c '401' /tmp/linux-workshop/access.log"

        explain "3. Most requests by IP:"
        run_command "awk '{print \$1}' /tmp/linux-workshop/access.log | sort | uniq -c | sort -rn | head -5"

        explain "4. Who accessed /admin:"
        run_command "grep '/admin' /tmp/linux-workshop/access.log"

        explain "5. Unique IPs:"
        run_command "awk '{print \$1}' /tmp/linux-workshop/access.log | sort -u | wc -l"
    fi
    pause
}

# ── Cheat Sheet ──────────────────────────────────────────────────────────────

cheat_sheet() {
    clear_screen
    section_header "Linux Admin Quick Reference"

    echo -e "  ${BOLD}${CYAN}── NAVIGATION ──${NC}"
    echo -e "  ${GREEN}pwd${NC}                        where am I?"
    echo -e "  ${GREEN}ls -lah${NC}                    list everything with details"
    echo -e "  ${GREEN}cd /path${NC}                   go to absolute path"
    echo -e "  ${GREEN}cd ..${NC}                      go up one level"
    echo -e "  ${GREEN}cd ~${NC}                       go home"
    echo -e "  ${GREEN}cd -${NC}                       go back to previous dir"
    echo ""
    echo -e "  ${BOLD}${CYAN}── FILES & DIRECTORIES ──${NC}"
    echo -e "  ${GREEN}mkdir -p path/to/dir${NC}       create nested directories"
    echo -e "  ${GREEN}touch file.txt${NC}             create empty file"
    echo -e "  ${GREEN}echo 'text' > file${NC}         write (overwrite) to file"
    echo -e "  ${GREEN}echo 'text' >> file${NC}        append to file"
    echo -e "  ${GREEN}cp -r source dest${NC}          copy (recursive for dirs)"
    echo -e "  ${GREEN}mv old new${NC}                 move or rename"
    echo -e "  ${GREEN}rm -r directory${NC}            delete directory"
    echo ""
    echo -e "  ${BOLD}${CYAN}── READING FILES ──${NC}"
    echo -e "  ${GREEN}cat file${NC}                   dump whole file"
    echo -e "  ${GREEN}head -n 20 file${NC}            first 20 lines"
    echo -e "  ${GREEN}tail -n 20 file${NC}            last 20 lines"
    echo -e "  ${GREEN}tail -f file${NC}               live follow (logs)"
    echo -e "  ${GREEN}less file${NC}                  scroll through file"
    echo -e "  ${GREEN}wc -l file${NC}                 count lines"
    echo ""
    echo -e "  ${BOLD}${CYAN}── EDITORS ──${NC}"
    echo -e "  ${GREEN}nano file${NC}                  easy editor (Ctrl+O save, Ctrl+X exit)"
    echo -e "  ${GREEN}vi file${NC}                    powerful editor (i=insert, Esc :wq=save+quit)"
    echo ""
    echo -e "  ${BOLD}${CYAN}── USERS & GROUPS ──${NC}"
    echo -e "  ${GREEN}useradd -m user${NC}            create user with home dir"
    echo -e "  ${GREEN}passwd user${NC}                set password"
    echo -e "  ${GREEN}userdel -r user${NC}            delete user + home dir"
    echo -e "  ${GREEN}usermod -aG group user${NC}     add user to group"
    echo -e "  ${GREEN}groupadd groupname${NC}         create a group"
    echo -e "  ${GREEN}id${NC}                         show current user/group info"
    echo -e "  ${GREEN}su - user${NC}                  switch to user"
    echo ""
    echo -e "  ${BOLD}${CYAN}── PERMISSIONS ──${NC}"
    echo -e "  ${GREEN}chmod 755 file${NC}             owner=rwx, group=r-x, other=r-x"
    echo -e "  ${GREEN}chmod 600 file${NC}             owner=rw-, nobody else"
    echo -e "  ${GREEN}chown user:group file${NC}      change ownership"
    echo -e "  ${GREEN}chown -R user:group dir/${NC}   recursive ownership change"
    echo ""
    echo -e "  ${BOLD}${CYAN}── SEARCHING & PIPES ──${NC}"
    echo -e "  ${GREEN}grep 'pattern' file${NC}        search for pattern"
    echo -e "  ${GREEN}grep -ri 'pattern' /dir${NC}    recursive, case-insensitive"
    echo -e "  ${GREEN}grep -c 'pattern' file${NC}     count matches"
    echo -e "  ${GREEN}command1 | command2${NC}        pipe output → input"
    echo ""
    echo -e "  ${BOLD}${CYAN}── IMPORTANT FILES ──${NC}"
    echo -e "  ${GREEN}/etc/passwd${NC}                user accounts"
    echo -e "  ${GREEN}/etc/shadow${NC}                password hashes (root only)"
    echo -e "  ${GREEN}/etc/group${NC}                 group memberships"
    echo -e "  ${GREEN}/etc/sudoers${NC}               sudo permissions (use visudo!)"
    echo ""
    echo -e "  ${BOLD}${CYAN}── COMPETITION FORENSICS ──${NC}"
    echo -e "  ${GREEN}grep ':0:' /etc/passwd${NC}     find accounts with root UID"
    echo -e "  ${GREEN}grep '/bin/bash' /etc/passwd${NC}  find accounts with shell access"
    echo -e "  ${GREEN}awk -F: '(\$2==\"\"){print \$1}' /etc/shadow${NC}  find empty passwords"

    pause
}

# ── Main Menu ────────────────────────────────────────────────────────────────

main_menu() {
    while true; do
        clear_screen
        banner

        echo -e "  ${BOLD}Modules:${NC}"
        echo ""
        echo -e "    ${CYAN}1${NC}  Getting Your Bearings"
        echo -e "       ${DIM}whoami, pwd, ls, cd, filesystem tree, tab completion${NC}"
        echo ""
        echo -e "    ${CYAN}2${NC}  Directories & File Paths"
        echo -e "       ${DIM}mkdir, mv, cp, rm, history, absolute vs relative paths${NC}"
        echo ""
        echo -e "    ${CYAN}3${NC}  Creating, Reading & Editing Files"
        echo -e "       ${DIM}touch, echo, cat, head, tail, nano, vi${NC}"
        echo ""
        echo -e "    ${CYAN}4${NC}  Users & Permissions"
        echo -e "       ${DIM}useradd, passwd, chmod, chown, sudo, sudoers${NC}"
        echo ""
        echo -e "    ${CYAN}5${NC}  Groups & Password Files"
        echo -e "       ${DIM}/etc/group, /etc/passwd, /etc/shadow, hash types${NC}"
        echo ""
        echo -e "    ${CYAN}6${NC}  Text Processing"
        echo -e "       ${DIM}less, grep, pipes, log analysis${NC}"
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
            1) module_terminal_basics ;;
            2) module_directories ;;
            3) module_files ;;
            4) module_users_permissions ;;
            5) module_groups_passwords ;;
            6) module_text_processing ;;
            c|C) cheat_sheet ;;
            a|A)
                module_terminal_basics
                module_directories
                module_files
                module_users_permissions
                module_groups_passwords
                module_text_processing
                cheat_sheet
                ;;
            q|Q)
                sandbox_cleanup
                echo ""
                echo -e "  ${GREEN}Keep practicing! Muscle memory is everything.${NC}"
                echo ""
                exit 0
                ;;
            *) echo -e "  ${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# ── Entry Point ──────────────────────────────────────────────────────────────

main_menu
