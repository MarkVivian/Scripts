#!/bin/bash

# prompt user for start up method.
# the -e allows for understanding of the underscore.
echo -e "what type of start up do you prefer: \n 1. using systemd \n 2. using cron jobs"
read -p "Choose:  " user_type

# Validate the user's input
if [[ $user_type -ne 1 ]] && [[ user_type -ne 2 ]]; then 
    # If the input is invalid, exit with an error message in red
    echo -e "\033[91mInvalid value typed\033[0m"
    exit
fi

# Prompt the user to provide the path of the script
echo "Please provide the path of the script: "

# the -e allows for path autocompletion 
read -e -p "Path: " user_path

# Define a function to extract the script name from the path
modify_path_function(){
    # Use rev and cut to extract the last part of the path (the script name)
    name=$(echo $real_path | rev | cut -d '/' -f 1 | rev)
    echo $name
}

# Define a function to create a systemd service file
systemd_function(){
    real_path=$1
    # Get the script name from the path
    script_name=$(modify_path_function)
    
    # Ask the user for a description (defaulting to "my script" if none is provided)
    read -p "Provide a description (my script : default ): " description
    if [ -z "$description" ]; then
        description="my script"
    fi

    service_name="$(echo $script_name | cut -d . -f 1)_script.service"
    
    # Create the systemd service file
    path="/etc/systemd/system/$service_name"

    file_creator=$(cat << EOF
[Unit]
Description= $description
After=network.target \n
[Service]
Type=simple 
ExecStart=$real_path 
Restart=on-failure
RestartSec=10 \n
[Install] 
WantedBy=multi-user.target  
EOF
)
    echo -e "privileges escalation required to create file in \n /etc/systemd/system"
    sudo bash -c "echo -e '$file_creator' > $path"

    echo -e "making the scripts executable \n\n"
    sudo chmod +x $user_path
    sudo chmod +x $path
    
    # Print a success message with the path of the created service file
    echo "Service created successfully at $path"
    # enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable $service_name
    sudo systemctl start $service_name

    # this checks the logs of the service.
    sudo journalctl -u $service_name
}

# Function to add color to text
color_text() {
  local text="$1"
  local color="$2"
  tput setaf $color
  echo "$text"
  tput sgr0
}

# tell the user how to use cron jobs
cron_jobs(){
    # Replace 'your_command' with the actual command to run
    crontab -l | { cat; echo "0 * * * * $1"; } | crontab -
    color_text "Cron job added successfully" green
}

# Check if the user-provided script path exists
if [ -e $user_path ]; then
    # If the path exists, call the appropriate function based on the user's choice
    if [[ $user_path == *~* ]]; then
        # will replace the ~ with /home/mark 
        user_path=$(eval echo $user_path)
    fi

    # Convert the user-provided path to an absolute path
    real_path=$(realpath $user_path)

    if [[ $user_type -eq 1 ]]; then
        systemd_function $real_path
    else
	    cron_jobs $real_path
    fi
else
    # If the path doesn't exist, exit with an error message in red
    echo -e "\033[91mThis file doesn't exist\033[0m"
    exit
fi
