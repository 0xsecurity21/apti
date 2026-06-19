#!/bin/bash

# Script to install and manage common security wordlists and resources
# Creates organized directory structure for different types of wordlists

# Base directory for all wordlists
WORDLISTS_DIR="$(pwd)/wordlists"

# Display warning and get user confirmation
echo "⚠️  WARNING: This script will download multiple wordlist repositories and files."
echo "   Estimated disk space required: ~8 GB"
echo "   Installation directory: $WORDLISTS_DIR"
echo
echo "Main components:"
echo "- SecLists (~3 GB)"
echo "- FuzzDB (~500 MB)"
echo "- PayloadsAllTheThings (~250 MB)"
echo "- Various wordlists and custom collections (~4 GB)"
echo
read -p "Do you want to proceed with the installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Function to clone or update a git repository
clone_or_update() {
    local repo_url="$1"
    local dir_name="$2"
    local target_dir="$WORDLISTS_DIR/$dir_name"
    
    if [ -d "$target_dir" ]; then
        echo "Updating $dir_name..."
        cd "$target_dir" || return
        git pull
        cd - > /dev/null
    else
        echo "Cloning $dir_name..."
        git clone "$repo_url" "$target_dir"
    fi
}

# Function to download file if it doesn't exist
download_if_not_exists() {
    local url="$1"
    local output_file="$2"
    local target_dir="$3"
    
    mkdir -p "$target_dir"
    if [ ! -f "$target_dir/$output_file" ]; then
        echo "Downloading $output_file..."
        curl -L "$url" -o "$target_dir/$output_file"
        
        # Handle gzipped files
        if [[ "$output_file" == *.gz ]]; then
            gunzip -f "$target_dir/$output_file"
        fi
    else
        echo "File $output_file already exists, skipping..."
    fi
}

echo "Installing wordlists and security resources..."

# Main repositories
echo "Cloning main wordlist repositories..."
clone_or_update "https://github.com/danielmiessler/SecLists.git" "seclists"
clone_or_update "https://github.com/fuzzdb-project/fuzzdb.git" "fuzzdb"
clone_or_update "https://github.com/swisskyrepo/PayloadsAllTheThings.git" "payloads"
clone_or_update "https://github.com/random-robbie/bruteforce-lists.git" "bruteforce"
clone_or_update "https://github.com/berzerk0/Probable-Wordlists.git" "probable-wordlists"
clone_or_update "https://github.com/xmendez/wfuzz.git" "wfuzz-lists"
clone_or_update "https://github.com/assetnote/wordlists.git" "assetnote"
clone_or_update "https://github.com/danielmiessler/RobotsDisallowed.git" "robots-disallowed"
clone_or_update "https://github.com/TheKingOfDuck/fuzzDicts.git" "fuzz-dicts"
clone_or_update "https://github.com/tennc/fuzzdb.git" "tennc-fuzzdb"

# Specialized directories
echo "Creating specialized wordlist directories..."

# Passwords directory
PASS_DIR="$WORDLISTS_DIR/passwords"
mkdir -p "$PASS_DIR"
download_if_not_exists "https://github.com/praetorian-inc/Hob0Rules/raw/master/wordlists/rockyou.txt.gz" "rockyou.txt.gz" "$PASS_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10k-most-common.txt" "10k-most-common.txt" "$PASS_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/top-passwords-shortlist.txt" "top-passwords-shortlist.txt" "$PASS_DIR"

# DNS directory
DNS_DIR="$WORDLISTS_DIR/dns"
mkdir -p "$DNS_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" "subdomains-top1million-5000.txt" "$DNS_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt" "deepmagic-prefixes-top50000.txt" "$DNS_DIR"
download_if_not_exists "https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt" "assetnote-best-dns.txt" "$DNS_DIR"

# Web content directory
WEB_DIR="$WORDLISTS_DIR/web"
mkdir -p "$WEB_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt" "common-paths.txt" "$WEB_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/api-endpoints.txt" "api-endpoints.txt" "$WEB_DIR"
download_if_not_exists "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/quickhits.txt" "quickhits.txt" "$WEB_DIR"

# Create convenient symbolic links
echo "Creating symbolic links for commonly used wordlists..."
cd "$WORDLISTS_DIR" || exit
ln -sf "seclists/Discovery/Web-Content/directory-list-2.3-medium.txt" "common-web-dirs.txt"
ln -sf "seclists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt" "common-passwords.txt"
ln -sf "seclists/Discovery/DNS/dns-Jhaddix.txt" "all-dns.txt"
ln -sf "passwords/rockyou.txt" "rockyou.txt"

echo "Wordlists installation completed!"
echo "Wordlists are installed in: $WORDLISTS_DIR"
echo
echo "Directory structure:"
echo "├── seclists/            (SecLists - comprehensive collection)"
echo "├── fuzzdb/              (FuzzDB attack patterns)"
echo "├── payloads/            (PayloadsAllTheThings)"
echo "├── bruteforce/          (Various bruteforce lists)"
echo "├── probable-wordlists/  (Probable password lists)"
echo "├── wfuzz-lists/         (WFuzz wordlists)"
echo "├── assetnote/           (Assetnote wordlists)"
echo "├── robots-disallowed/   (Common disallowed paths)"
echo "├── fuzz-dicts/          (Various fuzzing dictionaries)"
echo "├── tennc-fuzzdb/        (Extended fuzzdb collection)"
echo "├── passwords/           (Common password lists)"
echo "├── dns/                 (DNS and subdomain lists)"
echo "├── web/                 (Web content discovery)"
echo "└── Symbolic links:"
echo "    ├── common-web-dirs.txt"
echo "    ├── common-passwords.txt"
echo "    ├── all-dns.txt"
echo "    └── rockyou.txt" 