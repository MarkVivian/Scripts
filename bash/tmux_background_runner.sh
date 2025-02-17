#!/bin/bash

export DISPLAY=:0.0
export XAUTHORITY=/home/mark/.Xauthority
export PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native

# if you use an echo above the log exec in line 17 it will apear in journalctl -u service_name
# logging the script.
logfile="/var/log/script_logs/tmux_background_runner.log"
touch $logfile
chmod 755 $logfile

# Redirect stdout and stderr.
exec &> "$logfile"

sleep 60
echo "Script started at $(date)"

# this are for scripts with issues with the cron tab assignment.
scripts=("~/Documents/Scripts/bash/background_switcher.sh")

# Open a tmux server and pass the scripts provided.
# Create a tmux session named after the current user.
session_name=$(whoami)
tmux new-session -d -s $session_name
echo "session name is $session_name"

# Loop through each script in the scripts array.
for item in $scripts; do
    script_path=$item
    
    # Open a new tmux window (tab) for each script inside the existing tmux session.
    tmux new-window -t "$session_name" -n "$(basename "$script_path")" "bash -c '$script_path; bash'"
    notify-send "automated tmux" "the $item has been set appropriately"
done

# Detach from the tmux session.
tmux detach -s $session_name