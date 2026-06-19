#!/bin/bash

# Script to install pentesting tools that require custom installation methods
# This script will clone repositories and build tools from source when necessary

# Create a directory for custom tools
TOOLS_DIR="$HOME/security/custom-tools"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR" || exit

# Function to clone or update a git repository
clone_or_update() {
    local repo_url="$1"
    local dir_name="$2"
    if [ -d "$dir_name" ]; then
        echo "Updating $dir_name..."
        cd "$dir_name" || return
        git pull
        cd ..
    else
        echo "Cloning $dir_name..."
        git clone "$repo_url" "$dir_name"
    fi
}

# Install PowerShell tools
install_powershell_tools() {
    echo "Installing PowerShell tools..."
    clone_or_update "https://github.com/PowerShellMafia/PowerSploit.git" "PowerSploit"
    clone_or_update "https://github.com/samratashok/nishang.git" "nishang"
    clone_or_update "https://github.com/Kevin-Robertson/Inveigh.git" "Inveigh"
}

# Install custom Python tools
install_python_tools() {
    echo "Installing custom Python tools..."
    clone_or_update "https://github.com/trustedsec/unicorn.git" "unicorn"
    clone_or_update "https://github.com/lanmaster53/recon-ng.git" "recon-ng-src"
    clone_or_update "https://github.com/EmpireProject/Empire.git" "Empire"
}

# Install wordlists and resources
install_wordlists() {
    echo "Installing wordlists and resources..."
    clone_or_update "https://github.com/danielmiessler/SecLists.git" "SecLists"
    clone_or_update "https://github.com/fuzzdb-project/fuzzdb.git" "fuzzdb"
    clone_or_update "https://github.com/swisskyrepo/PayloadsAllTheThings.git" "PayloadsAllTheThings"
}

# Install custom C/C++ tools
install_c_tools() {
    echo "Installing C/C++ tools..."
    # Clone and build tools that require compilation
    clone_or_update "https://github.com/vanhauser-thc/thc-hydra.git" "hydra"
    if [ -d "hydra" ]; then
        cd hydra || return
        ./configure && make && sudo make install
        cd ..
    fi
}

# Install specialized tools
install_specialized_tools() {
    echo "Installing specialized tools..."
    # Hardware hacking tools
    clone_or_update "https://github.com/RfidResearchGroup/proxmark3.git" "proxmark3"
    # OSINT tools
    clone_or_update "https://github.com/laramies/theHarvester.git" "theHarvester"
    # Web application tools
    clone_or_update "https://github.com/s0md3v/XSStrike.git" "XSStrike"
}

# Main installation process
echo "Starting custom tools installation..."
install_powershell_tools
install_python_tools
install_wordlists
install_c_tools
install_specialized_tools

echo "Custom tools installation completed!"
echo "Tools are installed in: $TOOLS_DIR"
echo "Remember to check each tool's directory for specific setup instructions." 