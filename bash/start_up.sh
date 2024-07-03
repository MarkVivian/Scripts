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

# tell the user how to use cron jobs
cron_jobs(){
	echo -e "
            CRONTAB SYNTAX
        ========================
- A crontab file contains a list of jobs and their schedules.
- Each line in a crontab file represents a job and follows this syntax:
    EG.
        * * * * * command_to_run
        - - - - -
        | | | | |
        | | | | +---- Day of the week (0 - 7) (Sunday is both 0 and 7)
        | | | +------ Month (1 - 12)
        | | +-------- Day of the month (1 - 31)
        | +---------- Hour (0 - 23)
        +------------ Minute (0 - 59)



            CRONTAB EXAMPLES
        =======================
a) Run a command every minute.
    EG.
        * * * * * /path/to/command


b) Run a  command at 3:30AM every day.
    EG.
        30 3 * * * /path/to/command


c) Run a command at 5.00PM on the 1st and 15th of every month.
    EG.
        0 17 1,15 * * /path/to/command.


d)run a command every 5 minutes.
    EG.
        */5 * * * * /path/to/command.


e) run a command.
    EG.
        * * * * * echo "hello world!"


f) run multiple commands.
    EG.
        * * * * * /path/to/your/command1 && /path/to/your/command2




                    SPECIAL STRINGS.
                =========================
- Cron also supports special strings to represent common schedules:
    > @reboot: Run once at startup.
    > @yearly or @annually: Run once a year, equivalent to 0 0 1 1 *.
    > @monthly: Run once a month, equivalent to 0 0 1 * *.
    > @weekly: Run once a week, equivalent to 0 0 * * 0.
    > @daily or @midnight: Run once a day, equivalent to 0 0 * * *.
    > @hourly: Run once an hour, equivalent to 0 * * * *.
    

                    OUTPUT AND LOGGING.
                ===========================
- By default, cron sends output of the jobs to the user's email (if `MAILTO` is set).
- To log output to a file, redirect the output within the cron command.
    EG.
        * * * * * /path/to/command > /path/to/output.log 2>&1


- We can check the status of cron using:
    EG.
        systemctl status cron
	"

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
	cron_jobs
    fi
else
    # If the path doesn't exist, exit with an error message in red
    echo -e "\033[91mThis file doesn't exist\033[0m"
    exit
fi
