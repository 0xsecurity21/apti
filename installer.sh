#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m' 

main_menu() {
    printf "
     
    ${RED}(1) Install HomeBrew 🍺 (REQUIRED)${RESET}
    (2) Install Top 10 Pentesting Tools 🔨
    (3) Install Recommended Pentesting Tools 🔨
    (0) Exit ❌
     
    " 
}

install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! command -v brew 2>&1 >/dev/null
    then
        echo "Brew failed to install :( "
    else
       echo "Brew was successfully installed :) "
    fi
}

install_tools() {
    tools=(
        "nmap"
        "feroxbuster"
        "nikto"
        "metasploit --cask"
        "sqlmap"
        "burp-suite --cask"
        "john"
        "hashcat"
        "hydra"
        "aircrack-ng"
        "theharvester"
        "amass"
    )

    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        brew install $tool

        if ! command -v $(echo $tool | awk '{print $1}') 2>&1 >/dev/null
        then
            echo "$tool failed to install :("
        else
            echo "$tool was successfully installed :)"
        fi
    done
}

input() {
    case $1 in
        1) install_homebrew ;;
        # 2) install_tools ;;
        # 3) install_tools ;;
        4) echo -e "${GREEN}Exiting...${RESET}" ; exit ;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
    esac
}

while true; do
    main_menu
    read -p "→ " option
    input "$option"
    read -p "Press Enter to continue..."
done