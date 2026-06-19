#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

APT_DIR="$HOME/.apti"
INSTALL_LOG="$APT_DIR/installed.log"
CUSTOM_DIR="$APT_DIR/custom-tools"
WORDLIST_DIR="$APT_DIR/wordlists"
CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)/configs"
CONFIG_FILE="$CONFIG_DIR/config.json"
BOX_DIR="$HOME/htb"

mkdir -p "$APT_DIR" "$CUSTOM_DIR" "$WORDLIST_DIR" "$CONFIG_DIR"

BREW_FORMULAE=(
    nmap masscan rustscan tcpdump ngrep netcat socat
    nikto ffuf feroxbuster gobuster
    bettercap hydra metasploit ettercap mitmproxy proxychains-ng
    hashcat john crunch fcrackzip medusa
    amass theharvester dnsmap recon-ng
    binwalk foremost radare2 yara
    sslscan testssl sslh android-platform-tools
)

BREW_CASKS=(
    wireshark burp-suite zap ghidra cutter maltego osquery bloodhound
)

PIPX_TOOLS=(
    sqlmap wfuzz wafw00f dirsearch xsser whatweb droopescan nuclei
    scapy impacket crackmapexec netexec pypykatz certipy bloodhound wesng
    dnsrecon dnsenum dnstwist sublist3r photon fierce
    changeme hashid responder smbmap
    bandit safety trufflehog volatility3 oletools pefile
    frida-tools pwntools
)

GO_TOOLS=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest subfinder"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest httpx"
    "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest nuclei"
    "github.com/projectdiscovery/notify/cmd/notify@latest notify"
    "github.com/lc/gau/v2/cmd/gau@latest gau"
    "github.com/tomnomnom/waybackurls@latest waybackurls"
    "github.com/tomnomnom/assetfinder@latest assetfinder"
    "github.com/tomnomnom/unfurl@latest unfurl"
    "github.com/tomnomnom/qsreplace@latest qsreplace"
    "github.com/tomnomnom/gf@latest gf"
    "github.com/ffuf/ffuf/v2@latest ffuf"
    "github.com/owasp-amass/amass/v4/...@master amass"
    "github.com/projectdiscovery/katana/cmd/katana@latest katana"
    "github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest urlfinder"
    "github.com/sensepost/gowitness@latest gowitness"
)

GEM_TOOLS=(wpscan arachni ronin evil-winrm)

CUSTOM_REPOS=(
    "https://github.com/PowerShellMafia/PowerSploit.git PowerSploit"
    "https://github.com/samratashok/nishang.git nishang"
    "https://github.com/Kevin-Robertson/Inveigh.git Inveigh"
    "https://github.com/trustedsec/unicorn.git unicorn"
    "https://github.com/lanmaster53/recon-ng.git recon-ng"
    "https://github.com/s0md3v/XSStrike.git XSStrike"
    "https://github.com/RfidResearchGroup/proxmark3.git proxmark3"
    "https://github.com/peass-ng/PEASS-ng.git PEASS-ng"
    "https://github.com/itm4n/PrivescCheck.git PrivescCheck"
    "https://github.com/GhostPack/Seatbelt.git Seatbelt"
    "https://github.com/GhostPack/SharpUp.git SharpUp"
    "https://github.com/rasta-mouse/Watson.git Watson"
    "https://github.com/GhostPack/Rubeus.git Rubeus"
    "https://github.com/gentilkiwi/mimikatz.git mimikatz"
    "https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git Windows-Exploit-Suggester"
    "https://github.com/rasta-mouse/Sherlock.git Sherlock"
    "https://github.com/S3cur3Th1sSh1t/WinPwn.git WinPwn"
    "https://github.com/bitsadmin/wesng.git wesng"
    "https://github.com/Flangvik/SharpCollection.git SharpCollection"
)

WORDLIST_REPOS=(
    "https://github.com/danielmiessler/SecLists.git seclists"
    "https://github.com/fuzzdb-project/fuzzdb.git fuzzdb"
    "https://github.com/swisskyrepo/PayloadsAllTheThings.git payloads"
    "https://github.com/danielmiessler/RobotsDisallowed.git robots-disallowed"
)

WL_FILES_NAMES=(rockyou 10k-most-common subdomains-top1million common-web-paths)
WL_FILES_PATHS=(passwords/rockyou.txt passwords/10k-most-common.txt dns/subdomains-top1million-5000.txt web/common.txt)

usage() {
    echo "Usage: ./apti.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  configure         Interactive step-by-step configuration"
    echo "  install           Install enabled tools from configs/config.json"
    echo "  update            Update apti.sh itself from git"
    echo "  upgrade           Upgrade all installed tools"
    echo "  uninstall         Remove all installed tools and apti data"
    echo "  list              List all tools with config & install status"
    echo "  newbox <name> <ip>  Create HTB box dir & enumerate"
    echo "  configs           List available configs in configs/"
    exit 0
}

log_install() {
    echo "$1" >> "$INSTALL_LOG"
}

ensure_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}No configs/config.json found. Run './apti.sh configure' first.${RESET}"
        exit 1
    fi
}

json_get() {
    python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    config = json.load(f)
keys = '$1'.split('.')
val = config
for k in keys:
    if isinstance(val, dict) and k in val:
        val = val[k]
    else:
        sys.exit(1)
if isinstance(val, bool):
    print('true' if val else 'false')
elif isinstance(val, str):
    print(val)
"
}

is_enabled() {
    local result
    result=$(json_get "tools.$1.$2" 2>/dev/null) || return 1
    [ "$result" = "true" ]
}

config_status() {
    json_get "tools.$1.$2" 2>/dev/null || echo "true"
}

write_config() {
    python3 - "$CONFIG_FILE" "$1" "$2" "$3" "$4" << 'PYEOF'
import json, sys
filepath, key_path, value = sys.argv[1], sys.argv[2], sys.argv[3]
parts = key_path.split('.')
try:
    with open(filepath) as f:
        config = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    config = {}
obj = config
for k in parts[:-1]:
    if k not in obj or not isinstance(obj[k], dict):
        obj[k] = {}
    obj = obj[k]
if value in ('true', 'false'):
    obj[parts[-1]] = value == 'true'
else:
    obj[parts[-1]] = value
with open(filepath, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
PYEOF
}

check_xcode() {
    if ! xcode-select -p &>/dev/null; then
        echo -e "${YELLOW}Xcode Command Line Tools not found.${RESET}"
        read -p "$(echo -e 'Install Xcode CLI tools? ${GREEN}[Y/n]${RESET}: ')" ans
        case "$ans" in
            [Nn]*) echo -e "${YELLOW}Skipping Xcode CLI tools. Some tools may fail.${RESET}" ;;
            *) xcode-select --install
               echo -e "${GREEN}Xcode CLI tools installation prompted.${RESET}" ;;
        esac
    fi
}

check_brew() {
    if ! command -v brew &>/dev/null; then
        echo -e "${YELLOW}Homebrew not found.${RESET}"
        read -p "$(echo -e 'Install Homebrew? ${GREEN}[Y/n]${RESET}: ')" ans
        case "$ans" in
            [Nn]*) echo -e "${RED}Homebrew is required. Cannot proceed.${RESET}" ; exit 1 ;;
            *)
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if command -v brew &>/dev/null; then
                    log_install "homebrew"
                    echo -e "${GREEN}Homebrew installed.${RESET}"
                else
                    echo -e "${RED}Homebrew installation failed.${RESET}"
                    exit 1
                fi
                ;;
        esac
    fi
}

check_pipx() {
    if ! command -v pipx &>/dev/null; then
        echo -e "${YELLOW}pipx not found.${RESET}"
        read -p "$(echo -e 'Install pipx via brew? ${GREEN}[Y/n]${RESET}: ')" ans
        case "$ans" in
            [Nn]*) echo -e "${YELLOW}Skipping pipx. pipx tools will not be installed.${RESET}" ;;
            *) brew install pipx && pipx ensurepath
               echo -e "${GREEN}pipx installed.${RESET}" ;;
        esac
    fi
}

check_go() {
    if ! command -v go &>/dev/null; then
        echo -e "${YELLOW}Go not found.${RESET}"
        read -p "$(echo -e 'Install Go via brew? ${GREEN}[Y/n]${RESET}: ')" ans
        case "$ans" in
            [Nn]*) echo -e "${YELLOW}Skipping Go. Go tools will not be installed.${RESET}" ;;
            *) brew install go
               echo -e "${GREEN}Go installed.${RESET}" ;;
        esac
    fi
    export PATH="$HOME/go/bin:$PATH"
}

is_brew_installed() { brew list "$1" &>/dev/null; }
is_cask_installed() { brew list --cask "$1" &>/dev/null; }
is_pipx_installed() { pipx list --short 2>/dev/null | grep -q "^$1 "; }
is_go_installed() { command -v "$1" &>/dev/null; }
is_gem_installed() { gem list -i "$1" &>/dev/null; }
is_git_installed() { [ -d "$CUSTOM_DIR/$1" ]; }
is_wordlist_installed() { [ -d "$WORDLIST_DIR/$1" ]; }
is_file_installed() { [ -f "$WORDLIST_DIR/$1" ]; }

status_indicator() {
    if "$1" "$2"; then echo -e "${GREEN}[installed]${RESET}"
    else echo -e "${RED}[not installed]${RESET}"; fi
}

print_tool_line() {
    local name=$1 enabled=$2 install_status=$3
    if [ "$enabled" = "true" ]; then
        echo -e "  $name [enabled]  $install_status"
    else
        echo -e "  $name ${RED}[disabled]${RESET}  $install_status"
    fi
}

prompt_yn() {
    local label=$1 default=$2
    local prompt_str
    if [ "$default" = "y" ]; then
        prompt_str="$(echo -e "  ${label}? ${GREEN}[Y/n]${RESET}: ")"
    else
        prompt_str="$(echo -e "  ${label}? ${YELLOW}[y/N]${RESET}: ")"
    fi
    read -p "$prompt_str" ans
    case "$ans" in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) [ "$default" = "y" ] && return 0 || return 1 ;;
    esac
}

prompt_category() {
    local name=$1 count=$2
    echo ""
    echo -e "${CYAN}[$name]${RESET} ($count items)"
    read -p "$(echo -e "  Choose: ${GREEN}[Y]${RESET}es all / ${YELLOW}[n]${RESET}o all / ${CYAN}[c]${RESET}ustomize: ")" ans
    case "$ans" in
        [Cc]*) return 2 ;;
        [Nn]*) return 1 ;;
        *) return 0 ;;
    esac
}

configure_category() {
    local label=$1 count=$2 arr_ref=$3 has_go=$4 section=$5
    prompt_category "$label" "$count"
    local choice=$?
    local items=("${!arr_ref}")
    for entry in "${items[@]}"; do
        local tool="${entry##* }"
        if [ "$choice" = "2" ]; then
            if prompt_yn "  Install $tool" "y"; then
                write_config "tools.$section.$tool" "true"
            else
                write_config "tools.$section.$tool" "false"
            fi
        elif [ "$choice" = "1" ]; then
            write_config "tools.$section.$tool" "false"
        else
            write_config "tools.$section.$tool" "true"
        fi
    done
}

# ── configure ──────────────────────────────────────────

cmd_configure() {
    echo -e "${CYAN}========================================${RESET}"
    echo -e "${CYAN}  APTI - Interactive Configuration${RESET}"
    echo -e "${CYAN}========================================${RESET}"
    echo ""

    echo -e "${YELLOW}This will configure which tools to install.${RESET}"
    echo ""

    check_xcode
    check_brew
    check_pipx
    check_go

    python3 -c "
import json
config = {
    'tools': {
        'brew': {}, 'cask': {}, 'pipx': {}, 'go': {},
        'gem': {}, 'git': {}, 'wordlist': {}, 'files': {},
    },
    'bash': {
        'newbox_setup': 'mkdir -p \$dir/{nmap,exploit,content,enum,loot}',
        'nmap_initial': 'nmap -sC -sV -oN \$dir/nmap/initial \$ip',
        'nmap_full': 'nmap -p- -oN \$dir/nmap/full \$ip',
        'nmap_udp': 'nmap -sU --top-ports 100 -oN \$dir/nmap/udp \$ip',
        'enum_http': 'gobuster dir -u http://\$ip -w \$wordlists/raft-medium-directories.txt -o \$dir/enum/gobuster.txt 2>/dev/null',
        'enum_https': 'gobuster dir -k -u https://\$ip -w \$wordlists/raft-medium-directories.txt -o \$dir/enum/gobuster-ssl.txt 2>/dev/null',
        'enum_smb': 'smbclient -L //\$ip -N 2>/dev/null | tee \$dir/enum/smb.txt',
        'enum_rdp': 'nmap -p 3389 --script rdp-enum-encryption -oN \$dir/enum/rdp \$ip 2>/dev/null',
    },
    'files': {
        'custom_scan': '',
        'custom_enum': '',
    },
}
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"

    echo ""
    echo -e "${CYAN}--- Tool Categories ---${RESET}"
    echo ""

    # brew
    configure_category "Homebrew Formulae" "${#BREW_FORMULAE[@]}" BREW_FORMULAE[@] "" "brew"
    configure_category "Homebrew Casks" "${#BREW_CASKS[@]}" BREW_CASKS[@] "" "cask"
    configure_category "pipx Packages" "${#PIPX_TOOLS[@]}" PIPX_TOOLS[@] "" "pipx"
    configure_category "Go Tools" "${#GO_TOOLS[@]}" GO_TOOLS[@] "1" "go"
    configure_category "Ruby Gems" "${#GEM_TOOLS[@]}" GEM_TOOLS[@] "" "gem"

    configure_category "Custom Git Repos" "${#CUSTOM_REPOS[@]}" CUSTOM_REPOS[@] "" "git"
    configure_category "Wordlists (repos)" "${#WORDLIST_REPOS[@]}" WORDLIST_REPOS[@] "" "wordlist"

    prompt_category "Wordlists (files)" "${#WL_FILES_NAMES[@]}"
    wc=$?
    for i in "${!WL_FILES_NAMES[@]}"; do
        f="${WL_FILES_NAMES[$i]}"
        if [ "$wc" = "2" ]; then
            if prompt_yn "  Download $f" "y"; then
                write_config "tools.files.$f" "true"
            else
                write_config "tools.files.$f" "false"
            fi
        elif [ "$wc" = "1" ]; then
            write_config "tools.files.$f" "false"
        else
            write_config "tools.files.$f" "true"
        fi
    done

    echo ""
    echo -e "${GREEN}[+] Configuration saved to configs/config.json${RESET}"
    echo -e "  Run ${CYAN}./apti.sh install${RESET} to install selected tools."
    echo -e "  Edit bash commands in configs/config.json for box automation."
}

# ── install ────────────────────────────────────────────

cmd_install() {
    ensure_config
    echo -e "${CYAN}[*] Starting installation...${RESET}"

    check_xcode
    check_brew
    check_pipx
    check_go

    echo -e "${BLUE}[+] Installing Homebrew formulae...${RESET}"
    for tool in "${BREW_FORMULAE[@]}"; do
        if is_enabled "brew" "$tool"; then
            echo -e "  Installing $tool..."
            brew install "$tool" 2>/dev/null && log_install "brew:$tool" || echo -e "  ${YELLOW}Warning: $tool failed.${RESET}"
        fi
    done

    echo -e "${BLUE}[+] Installing Homebrew casks...${RESET}"
    for cask in "${BREW_CASKS[@]}"; do
        if is_enabled "cask" "$cask"; then
            echo -e "  Installing $cask..."
            brew install --cask "$cask" 2>/dev/null && log_install "cask:$cask" || echo -e "  ${YELLOW}Warning: $cask failed.${RESET}"
        fi
    done

    echo -e "${BLUE}[+] Installing pipx packages...${RESET}"
    for tool in "${PIPX_TOOLS[@]}"; do
        if is_enabled "pipx" "$tool"; then
            echo -e "  Installing $tool..."
            if is_pipx_installed "$tool"; then
                echo -e "  ${YELLOW}$tool already installed, skipping.${RESET}"
            else
                pipx install "$tool" 2>/dev/null && log_install "pipx:$tool" || echo -e "  ${YELLOW}Warning: $tool failed.${RESET}"
            fi
        fi
    done

    echo -e "${BLUE}[+] Installing Go tools...${RESET}"
    for entry in "${GO_TOOLS[@]}"; do
        name="${entry##* }"
        if is_enabled "go" "$name"; then
            echo -e "  Installing $name..."
            go install "${entry%% *}" 2>/dev/null && log_install "go:$name" || echo -e "  ${YELLOW}Warning: $name failed.${RESET}"
        fi
    done

    echo -e "${BLUE}[+] Installing Ruby gems...${RESET}"
    for gem in "${GEM_TOOLS[@]}"; do
        if is_enabled "gem" "$gem"; then
            echo -e "  Installing $gem..."
            gem install "$gem" 2>/dev/null && log_install "gem:$gem" || echo -e "  ${YELLOW}Warning: $gem failed.${RESET}"
        fi
    done

    echo -e "${BLUE}[+] Cloning custom tool repos...${RESET}"
    for entry in "${CUSTOM_REPOS[@]}"; do
        url="${entry%% *}"
        dir="${entry##* }"
        if is_enabled "git" "$dir"; then
            target="$CUSTOM_DIR/$dir"
            if [ -d "$target" ]; then
                echo -e "  Updating $dir..."
                (cd "$target" && git pull) 2>/dev/null
            else
                echo -e "  Cloning $dir..."
                git clone --depth 1 "$url" "$target" 2>/dev/null
            fi
            log_install "git:$dir"
        fi
    done

    echo -e "${BLUE}[+] Downloading wordlists...${RESET}"
    for entry in "${WORDLIST_REPOS[@]}"; do
        dir="${entry##* }"
        if is_enabled "wordlist" "$dir"; then
            target="$WORDLIST_DIR/$dir"
            if [ -d "$target" ]; then
                echo -e "  Updating $dir..."
                (cd "$target" && git pull) 2>/dev/null
            else
                echo -e "  Cloning $dir..."
                git clone --depth 1 "${entry%% *}" "$target" 2>/dev/null
            fi
            log_install "wordlist:$dir"
        fi
    done

    PASS_DIR="$WORDLIST_DIR/passwords"
    mkdir -p "$PASS_DIR"
    if is_enabled "files" "rockyou" && [ ! -f "$PASS_DIR/rockyou.txt" ]; then
        echo -e "  Downloading rockyou.txt..."
        curl -L "https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz" -o "$PASS_DIR/rockyou.txt.gz" 2>/dev/null
        gunzip -f "$PASS_DIR/rockyou.txt.gz" 2>/dev/null && log_install "wordlist:rockyou"
    fi
    if is_enabled "files" "10k-most-common" && [ ! -f "$PASS_DIR/10k-most-common.txt" ]; then
        echo -e "  Downloading 10k-most-common.txt..."
        curl -L "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt" -o "$PASS_DIR/10k-most-common.txt" 2>/dev/null && log_install "wordlist:10k-most-common"
    fi
    if is_enabled "files" "subdomains-top1million" && [ ! -f "$WORDLIST_DIR/dns/subdomains-top1million-5000.txt" ]; then
        mkdir -p "$WORDLIST_DIR/dns"
        curl -L "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" -o "$WORDLIST_DIR/dns/subdomains-top1million-5000.txt" 2>/dev/null && log_install "wordlist:subdomains-top1million"
    fi
    if is_enabled "files" "common-web-paths" && [ ! -f "$WORDLIST_DIR/web/common.txt" ]; then
        mkdir -p "$WORDLIST_DIR/web"
        curl -L "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt" -o "$WORDLIST_DIR/web/common.txt" 2>/dev/null && log_install "wordlist:common-web"
    fi

    echo -e "${GREEN}[+] Installation complete!${RESET}"
    echo -e "  Custom tools: $CUSTOM_DIR"
    echo -e "  Wordlists: $WORDLIST_DIR"
}

# ── update / upgrade / uninstall / list ────────────────

cmd_update() {
    echo -e "${CYAN}[*] Updating apti.sh...${RESET}"
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -d "$SCRIPT_DIR/.git" ]; then
        git -C "$SCRIPT_DIR" pull
        echo -e "${GREEN}[+] apti.sh updated.${RESET}"
    else
        echo -e "${YELLOW}Not a git repository. Cannot update.${RESET}"
    fi
}

cmd_upgrade() {
    echo -e "${CYAN}[*] Upgrading all installed tools...${RESET}"
    if [ ! -f "$INSTALL_LOG" ]; then
        echo -e "${YELLOW}No installation log found. Run './apti.sh install' first.${RESET}"
        return
    fi

    BREW_TOOLS=(); PIPX_TOOLS_UP=(); GEM_TOOLS_UP=()
    while IFS= read -r line; do
        case "$line" in
            brew:*) BREW_TOOLS+=("${line#brew:}") ;;
            cask:*) BREW_TOOLS+=("${line#cask:}") ;;
            pipx:*) PIPX_TOOLS_UP+=("${line#pipx:}") ;;
            gem:*)  GEM_TOOLS_UP+=("${line#gem:}") ;;
        esac
    done < "$INSTALL_LOG"

    [ ${#BREW_TOOLS[@]} -gt 0 ] && echo -e "${BLUE}[+] Upgrading Homebrew packages...${RESET}" && brew upgrade "${BREW_TOOLS[@]}" 2>/dev/null || true
    [ ${#PIPX_TOOLS_UP[@]} -gt 0 ] && echo -e "${BLUE}[+] Upgrading pipx packages...${RESET}" && for t in "${PIPX_TOOLS_UP[@]}"; do pipx upgrade "$t" 2>/dev/null || true; done
    [ ${#GEM_TOOLS_UP[@]} -gt 0 ] && echo -e "${BLUE}[+] Upgrading Ruby gems...${RESET}" && gem update "${GEM_TOOLS_UP[@]}" 2>/dev/null || true

    echo -e "${BLUE}[+] Updating Go tools...${RESET}"
    for entry in "${GO_TOOLS[@]}"; do go install "${entry%% *}" 2>/dev/null || true; done
    for dir in "$CUSTOM_DIR"/*/; do [ -d "$dir/.git" ] && echo -e "  Updating $(basename "$dir")..." && (cd "$dir" && git pull) 2>/dev/null || true; done
    for dir in "$WORDLIST_DIR"/*/; do [ -d "$dir/.git" ] && echo -e "  Updating $(basename "$dir")..." && (cd "$dir" && git pull) 2>/dev/null || true; done
    echo -e "${GREEN}[+] Upgrade complete.${RESET}"
}

cmd_uninstall() {
    echo -e "${RED}[!] Uninstalling all tools...${RESET}"
    if [ ! -f "$INSTALL_LOG" ]; then
        rm -rf "$APT_DIR"
        echo -e "${GREEN}[+] Done.${RESET}"
        return
    fi

    BREW_TOOLS=(); CASK_TOOLS=(); PIPX_TOOLS_U=(); GEM_TOOLS_U=()
    while IFS= read -r line; do
        case "$line" in
            brew:*) BREW_TOOLS+=("${line#brew:}") ;;
            cask:*) CASK_TOOLS+=("${line#cask:}") ;;
            pipx:*) PIPX_TOOLS_U+=("${line#pipx:}") ;;
            gem:*)  GEM_TOOLS_U+=("${line#gem:}") ;;
        esac
    done < "$INSTALL_LOG"

    for t in "${BREW_TOOLS[@]}"; do brew uninstall "$t" 2>/dev/null || true; done
    for c in "${CASK_TOOLS[@]}"; do brew uninstall --cask "$c" 2>/dev/null || true; done
    for t in "${PIPX_TOOLS_U[@]}"; do pipx uninstall "$t" 2>/dev/null || true; done
    for entry in "${GO_TOOLS[@]}"; do rm -f "$HOME/go/bin/${entry##* }" 2>/dev/null || true; done
    for g in "${GEM_TOOLS_U[@]}"; do gem uninstall "$g" 2>/dev/null || true; done

    rm -rf "$CUSTOM_DIR" "$WORDLIST_DIR" "$APT_DIR"
    echo -e "${GREEN}[+] Uninstall complete. apti.sh and configs/ remain.${RESET}"
}

cmd_list() {
    ensure_config
    echo -e "${CYAN}=================== Tool Inventory ===================${RESET}"
    echo ""

    echo -e "${BLUE}--- Homebrew Formulae ---${RESET}"
    for tool in "${BREW_FORMULAE[@]}"; do print_tool_line "$tool" "$(config_status brew "$tool")" "$(status_indicator is_brew_installed "$tool")"; done
    echo ""
    echo -e "${BLUE}--- Homebrew Casks ---${RESET}"
    for cask in "${BREW_CASKS[@]}"; do print_tool_line "$cask" "$(config_status cask "$cask")" "$(status_indicator is_cask_installed "$cask")"; done
    echo ""
    echo -e "${BLUE}--- pipx Packages ---${RESET}"
    for tool in "${PIPX_TOOLS[@]}"; do print_tool_line "$tool" "$(config_status pipx "$tool")" "$(status_indicator is_pipx_installed "$tool")"; done
    echo ""
    echo -e "${BLUE}--- Go Tools ---${RESET}"
    for entry in "${GO_TOOLS[@]}"; do name="${entry##* }"; print_tool_line "$name" "$(config_status go "$name")" "$(status_indicator is_go_installed "$name")"; done
    echo ""
    echo -e "${BLUE}--- Ruby Gems ---${RESET}"
    for gem in "${GEM_TOOLS[@]}"; do print_tool_line "$gem" "$(config_status gem "$gem")" "$(status_indicator is_gem_installed "$gem")"; done
    echo ""
    echo -e "${BLUE}--- Custom Git Repos ---${RESET}"
    for entry in "${CUSTOM_REPOS[@]}"; do dir="${entry##* }"; print_tool_line "$dir" "$(config_status git "$dir")" "$(status_indicator is_git_installed "$dir")"; done
    echo ""
    echo -e "${BLUE}--- Wordlists ---${RESET}"
    for entry in "${WORDLIST_REPOS[@]}"; do dir="${entry##* }"; print_tool_line "$dir" "$(config_status wordlist "$dir")" "$(status_indicator is_wordlist_installed "$dir")"; done
    for i in "${!WL_FILES_NAMES[@]}"; do
        n="${WL_FILES_NAMES[$i]}"; p="${WL_FILES_PATHS[$i]}"
        print_tool_line "$n" "$(config_status files "$n")" "$(status_indicator is_file_installed "$p")"
    done
    echo ""
    echo -e "${CYAN}====================================================${RESET}"
}

# ── newbox ─────────────────────────────────────────────

cmd_newbox() {
    local name=$1 ip=$2
    if [ -z "$name" ] || [ -z "$ip" ]; then
        echo -e "${RED}Usage: ./apti.sh newbox <name> <ip>${RESET}"
        exit 1
    fi

    local dir="$BOX_DIR/$name"
    local wordlists="$WORDLIST_DIR/seclists/Discovery/Web-Content"

    echo -e "${CYAN}[*] Setting up box: $name ($ip)${RESET}"
    echo ""

    # create dirs
    echo -e "${BLUE}[+] Creating directories...${RESET}"
    mkdir -p "$dir/nmap" "$dir/exploit" "$dir/content" "$dir/enum" "$dir/loot"

    # save IP
    echo "$ip" > "$dir/ip.txt"
    echo -e "  $dir"

    # run bash commands from config
    echo -e "${BLUE}[+] Running configured scans...${RESET}"
    echo ""

    if [ -f "$CONFIG_FILE" ]; then
        python3 -c "
import json, subprocess, sys, os
with open('$CONFIG_FILE') as f:
    config = json.load(f)
cmds = config.get('bash', {})
env = os.environ.copy()
env['dir'] = '$dir'
env['ip'] = '$ip'
env['wordlists'] = '$wordlists'
for name, cmd in sorted(cmds.items()):
    if not cmd:
        continue
    print(f'  Running {name}...')
    try:
        subprocess.run(cmd, shell=True, env=env, timeout=300)
    except subprocess.TimeoutExpired:
        print(f'  {YELLOW}Timed out: {name}{RESET}')
" 2>/dev/null || echo -e "  ${YELLOW}No bash commands found in config.${RESET}"
    fi

    # run custom file scripts from config
    if [ -f "$CONFIG_FILE" ]; then
        python3 -c "
import json, subprocess, os
with open('$CONFIG_FILE') as f:
    config = json.load(f)
files = config.get('files', {})
env = os.environ.copy()
env['dir'] = '$dir'
env['ip'] = '$ip'
env['wordlists'] = '$wordlists'
for name, path in files.items():
    if not path or not os.path.isfile(path):
        continue
    print(f'  Sourcing {name} ({path})...')
    subprocess.run(['bash', path], env=env)
" 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}[+] Box setup complete: $name${RESET}"
    echo -e "  Dir: $dir"
    echo -e "  IP:  $ip"
    echo -e "  ${YELLOW}Review scans in $dir/nmap/ and $dir/enum/${RESET}"
}

# ── configs ────────────────────────────────────────────

cmd_configs() {
    echo -e "${CYAN}[*] Available configs in configs/:${RESET}"
    echo ""
    for f in "$CONFIG_DIR"/*.json; do
        [ -f "$f" ] || continue
        echo -e "  ${BLUE}$(basename "$f")${RESET}"
        python3 -c "
import json
with open('$f') as fh:
    c = json.load(fh)
tools = c.get('tools', {})
total = sum(len(v) for v in tools.values() if isinstance(v, dict))
bash_count = len(c.get('bash', {}))
print(f'      tools: $total entries, bash: $bash_count commands')
" 2>/dev/null
    done
}

# ── entry ──────────────────────────────────────────────

case "${1:-help}" in
    configure) cmd_configure ;;
    install)   cmd_install ;;
    update)    cmd_update ;;
    upgrade)   cmd_upgrade ;;
    uninstall) cmd_uninstall ;;
    list)      cmd_list ;;
    newbox)    cmd_newbox "$2" "$3" ;;
    configs)   cmd_configs ;;
    *)         usage ;;
esac
