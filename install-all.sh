#!/bin/bash

# Main script to install pentesting tools on macOS
# Assumes Homebrew is installed and Python virtual environment is activated

# Exit on any error
set -e

# Check for required dependencies
echo "⚠️  This script requires the following dependencies:"
echo "- Homebrew (brew)"
echo "- Git"
echo "- Python 3"
echo "- Ruby"
echo
echo "Additionally, a Python virtual environment must be activated before proceeding."
echo "You can create and activate one with:"
echo "python3 -m venv .venv"
echo "source .venv/bin/activate"
echo

# Check if virtual environment is active
if [[ -z "${VIRTUAL_ENV}" ]]; then
    echo "Error: Python virtual environment is not activated"
    echo "Please activate a virtual environment and try again"
    exit 1
fi

read -p "Do you want to proceed with the installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

echo "Starting installation of pentesting tools..."

# Run Homebrew installations
echo "Running Homebrew installations..."
bash install_brew_tools.sh

# Run pip installations
echo "Running pip installations..."
bash install_pip_tools.sh

# Run Ruby gems installations
echo "Running gem installations..."
bash install_gems.sh

# Run custom installations for tools not in Homebrew or pip
echo "Running custom installations..."
bash install_custom_tools.sh

echo "Pentesting tools installation completed!"
echo "Tools are installed in ~/pentest"
echo "Ensure your Python virtual environment is activated when using pip-installed tools."
echo "You can download wordlists with the following command:"
echo "bash install_wordlists.sh"