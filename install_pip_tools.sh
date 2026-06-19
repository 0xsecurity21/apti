#!/bin/bash

# Script to install pentesting tools using pip
# Assumes Python virtual environment is activated
# Installs tools in the virtual environment, skips unavailable packages

# List of pentesting tools available via pip, inspired by sidaf/homebrew-pentest
PIP_TOOLS=(
    ###########################################
    # Web Application Security
    ###########################################
    sqlmap           # Automated SQL injection tool
    wfuzz            # Web application fuzzer
    wafw00f          # Web application firewall fingerprinting
    dirsearch        # Web path scanner
    xsser            # Cross Site Scripting (XSS) scanner
    nikto3           # Web server scanner in Python
    whatweb          # Web application fingerprinting
    droopescan       # CMS scanner (Drupal, WordPress, etc.)
    wpscan-cli       # WordPress vulnerability scanner
    nuclei           # Vulnerability scanner

    ###########################################
    # Network Security & Analysis
    ###########################################
    scapy            # Packet manipulation tool
    impacket         # Network protocols scripts
    pycurl           # HTTP client library for web testing
    requests         # HTTP library for Python
    pyrdp            # RDP man-in-the-middle tool

    ###########################################
    # Active Directory & Windows
    ###########################################
    crackmapexec     # Post-exploitation tool for Active Directory
    pypykatz         # Mimikatz implementation in Python
    dploot           # Active Directory certificate exploitation
    certipy          # Active Directory certificate abuse
    bloodhound       # Active Directory analysis tool
    wesng            # Windows Exploit Suggester

    ###########################################
    # Information Gathering
    ###########################################
    dnsrecon         # DNS enumeration tool
    dnsenum          # DNS enumeration tool
    dnstwist         # Domain name permutation engine
    sublist3r        # Subdomain enumeration tool
    photon           # Web crawler and recon tool
    fierce           # DNS reconnaissance tool

    ###########################################
    # Password & Credential Testing
    ###########################################
    changeme         # Default credential scanner
    hashid           # Hash identifier
    pydictor         # Password dictionary builder

    ###########################################
    # Exploitation & Post-Exploitation
    ###########################################
    routersploit     # Framework for exploiting embedded devices
    empire           # Post-exploitation framework
    responder        # LLMNR/NBT-NS/MDNS poisoner
    smbmap           # SMB enumeration tool

    ###########################################
    # Code Analysis & Security
    ###########################################
    bandit           # Security linter for Python code
    safety           # Checks Python dependencies for known vulnerabilities
    trufflehog       # Searches for secrets in git repositories

    ###########################################
    # Forensics & Binary Analysis
    ###########################################
    volatility3     # Memory forensics framework
    oletools        # Microsoft Office file analysis
    pyexfil         # Data exfiltration toolkit
    pefile          # PE file analysis
    angr            # Binary analysis framework

    ###########################################
    # Dynamic Analysis & Instrumentation
    ###########################################
    frida-tools     # Dynamic instrumentation toolkit
    pwntools        # CTF framework and exploit development
)

echo "Installing pip pentesting tools..."
for tool in "${PIP_TOOLS[@]}"; do
    echo "Installing $tool..."
    pip3 install "$tool" || echo "Warning: $tool not available in pip, skipping..."
done

echo "pip installations completed."