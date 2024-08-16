#!/bin/bash

# Check if the script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo."
  exit 1
fi

# Define the log directory path
log_dir="/var/log/script_logs"

# Check if the log directory exists
if [[ ! -d "$log_dir" ]]; then
  # Create the log directory with the correct ownership and permissions
  sudo mkdir -p "$log_dir"
  sudo chown "$USER:$USER" "$log_dir"
  echo "Log directory created: $log_dir"
else
  echo "Log directory already exists: $log_dir"
fi