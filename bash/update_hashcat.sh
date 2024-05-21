#!/bin/bash

# Navigate to the hashcat source directory
cd /opt/hashcat

# Pull the latest changes from the repository
git pull

# Clean previous builds
sudo make clean

# Compile the new version
sudo make

# Install the new version
sudo make install
