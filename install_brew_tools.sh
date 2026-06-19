#!/bin/bash

# Script to install pentesting tools using Homebrew
# Ignores unavailable packages and proceeds with available ones

echo "Adding Homebrew tap for pentest tools..."
# brew tap sidaf/pentest 2>/dev/null || true

# List of common pentesting tools available via Homebrew
BREW_FORMULAE=(
    ###########################################
    # Network Analysis & Scanning
    ###########################################
    nmap                        # Port scanning tool with Zenmap
    masscan                     # Fast port scanner
    rustscan                    # Fast port scanner
    tcpdump                     # Network packet analyzer
    ngrep                       # Network packet analyzer
    p0f                         # Passive OS fingerprinting
    netcat                      # Network utility for reading/writing
    socat                       # Multipurpose relay tool

    ###########################################
    # Web Application Testing
    ###########################################
    sqlmap                      # Automated SQL injection tool
    nikto                       # Web server scanner
    ffuf                        # Fast web fuzzer
    feroxbuster                # Fast content discovery tool
    gobuster                    # Directory/file brute-forcing
    wpscan                      # WordPress vulnerability scanner

    ###########################################
    # Network Attack & Exploitation
    ###########################################
    bettercap                   # Network attack and monitoring tool
    hydra                       # Password cracking tool
    metasploit                  # Penetration testing framework
    ettercap                    # Network protocol analyzer/MITM
    mitmproxy                   # Interactive HTTPS proxy
    proxychains-ng             # Proxy chaining tool

    ###########################################
    # Password & Hash Tools
    ###########################################
    hashcat                     # Advanced password recovery
    john                        # Password cracker
    crunch                      # Wordlist generator
    fcrackzip                   # Zip password cracker
    hashdeep                    # Hashing tool
    medusa                      # Fast password cracker

    ###########################################
    # Information Gathering
    ###########################################
    amass                       # Network mapping of attack surfaces
    subfinder                   # Subdomain discovery tool
    theharvester                # Information gathering tool
    dnsmap                      # Passive DNS network mapper
    recon-ng                    # Web reconnaissance framework

    ###########################################
    # Forensics & Analysis
    ###########################################
    binwalk                     # Firmware analysis tool
    foremost                    # File carving tool
    radare2                     # Reverse engineering framework
    yara                        # Pattern matching for malware researchers

    ###########################################
    # SSL/TLS Testing
    ###########################################
    sslscan                     # SSL/TLS scanner
    testssl                     # SSL/TLS security testing
    sslh                        # SSL/SSH multiplexer

    ###########################################
    # Android Tools
    ###########################################
    android-platform-tools      # Android debugging and development tools
)

# List of pentesting tools available via Homebrew casks
BREW_CASKS=(
    ###########################################
    # Network Analysis GUI Tools
    ###########################################
    wireshark                  # Network protocol analyzer
    burp-suite                 # Web vulnerability scanner (community edition)
    zap                        # OWASP ZAP for web app testing

    ###########################################
    # Reverse Engineering & Binary Analysis
    ###########################################
    ghidra                     # Software reverse engineering framework
    cutter                     # Reverse engineering platform
    binary-ninja               # Binary analysis platform
    hopper-disassembler        # Reverse engineering tool
    ida-free                   # Disassembler

    ###########################################
    # OSINT & Reconnaissance
    ###########################################
    maltego                    # Interactive data mining tool

    ###########################################
    # System Analysis & Monitoring
    ###########################################
    osquery                    # Security analytics tool
)

echo "Installing Homebrew pentesting formulae..."
for tool in "${BREW_FORMULAE[@]}"; do
    echo "Installing $tool..."
    brew install "$tool" || echo "Warning: $tool not available in Homebrew formulae, skipping..."
done

echo "Installing Homebrew pentesting casks..."
for cask in "${BREW_CASKS[@]}"; do
    echo "Installing $cask..."
    brew install --cask "$cask" || echo "Warning: $cask not available in Homebrew casks, skipping..."
done

echo "Homebrew installations completed."