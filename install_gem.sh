#!/bin/bash

# Script to install Ruby gem-based pentesting tools
# Assumes Ruby is installed (e.g., via brew install ruby)
# Installs gems globally, shows all command outputs, and uses a generic emoji-marked error message
# Uses a loop for gem installations, with each in a separate function for modularity

# List of Ruby gems for pentesting
GEM_TOOLS=(
    ###########################################
    # Web Application Security
    ###########################################
    wpscan                      # WordPress vulnerability scanner
    arachni                     # Web application security scanner

    ###########################################
    # Exploitation Frameworks
    ###########################################
    ronin                       # Ruby framework for pentesting
)

echo "Installing Ruby gem-based pentesting tools..."

# Loop through gems and install each
for gem in "${GEM_TOOLS[@]}"; do
  echo "Installing $gem..."
  gem install "$gem" || echo "🚫 Failed to install $gem"
done

echo "Ruby gem installations finished."