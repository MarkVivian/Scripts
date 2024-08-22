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

    # provide the [Unit] after and [Install] WantedBy else we will use the default
    # get the list of *.wants and remove the .wants from them and store in an array.
    wants_list=($(ls /etc/systemd/system/ | grep wants | sed "s/.wants//g"))

    echo "service modes in your pc:"
    for (( i=0; i<${#wants_list[@]}; i++ )); do
        echo "$i. ${wants_list[$i]}"
    done
    read -p "Provide the [Unit] after (default: multi-user.target): " after

    # make sure that variable $after and $WantedBy are intergers and between 0 and length of $wants_list array.
    wants_list_length=${#wants_list[@]}
    # check if after and wantedBy are empty
    if [ -z "$after" ]; then
        after_value=multi-user.target
        echo "using : $after_value"
    else 
        if [[ "$after" =~ ^[0-9]+$ ]]; then  
            if [[ "$after" -ge 0 && "$after" -lt $wants_list_length ]]; then
                after_value=${wants_list[$after]}
                echo "chose $after_value"
            else   
                echo "provide a value within the range 0 to $(($wants_list_length - 1))"
                exit
            fi 
        else 
            echo "please provide intergers"
            exit 1
        fi 
    fi  

    read -p "Provide the [Install] WantedBy (default: multi-user.target) : " WantedBy

    if [ -z "$WantedBy" ]; then 
        wanted_value=multi-user.target
        echo "using : $wanted_value"
    else 
        if [[ "$WantedBy" =~ ^[0-9]+$ ]]; then
            if [[ "$WantedBy" -ge 0 && "$WantedBy" -lt $wants_list_length ]]; then
                wanted_value=${wants_list[$WantedBy]}
                echo "chose $wanted_value"
            else   
                echo "provide a value within the range 0 to $(($wants_list_length - 1))"
                exit 1
            fi
        else 
            echo "please provide an interger"
            exit 1
        fi  
    fi 

    # get the environment if needed..
    read -p "do you wish to use environments (y/n : default:n): " answer

    if ! [ -z "$answer" ]; then
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then 
            # environment handling.
            echo "provide environments if any required (type done when finished): "
            echo "format: HOME=/home/$USER"

            while true; do  
                read -p "Environment variable : " env_var

                if [[ "$env_var" == "done" ]]; then
                    echo "done with environment variables"
                    break 
                fi 
                user_environment+="\nEnvironment=\"$env_var\"" 
            done
        fi
    fi

    echo -e "the chosen user environment is $user_environment"
   
    # form the service name.
    service_name="$(echo $script_name | cut -d . -f 1)_script.service"
    
    # Create the systemd service file
    path="/etc/systemd/system/$service_name"

    file_creator=$(cat << EOF
[Unit]
Description= $description
After=$after_value \n

[Service]
Type=simple 
Environment="USER=$USER"
Environment="HOME=$HOME" $user_environment
ExecStart=$real_path 
Restart=on-failure
RestartSec=10 \n

[Install] 
WantedBy=$wanted_value 
EOF
)
    echo -e "privileges escalation required to create file in \n /etc/systemd/system"
    sudo bash -c "echo -e '$file_creator' > $path"

    echo -e "making the scripts executable \n"
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

# add to crontab .
cron_jobs(){
    local script_path="$1"

    # provide choices for crontab.
    read -p "do you wish to use: \n 1. custom schedules \n 2.pre-made schedules : \n " choice
    case "$choice" in
        "1")
            echo "Please use Intergers: "
            read -p "Day of the week (0 - 7) (Sunday is both 0 and 7) (* to ignore): " day
            read -p "month (1 - 12) (* to ignore) " month
            read -p "Day of the month (* to ignore)" dayMonth
            read -p "Hour (0 - 23) (* to ignore)" hour
            read -p "Minute (0 - 59) (* to ignore)" minute

            # Validate custom schedule inputs
            if [[ ! "$day" =~ ^[0-7*]$ ]] || [[ ! "$month" =~ ^[1-12*]$ ]] ||
            [[ ! "$dayMonth" =~ ^[1-31*]$ ]] || [[ ! "$hour" =~ ^[0-23*]$ ]] ||
            [[ ! "$minute" =~ ^[0-59*]$ ]]; then
                echo "Invalid input for custom schedule. Please use integers within the specified ranges."
                return 1
            fi


            monkey="$minute $hour $dayMonth $month $day"
            ;;
        "2")
            read -p "What do you choose: \n 
                    1. @reboot: Run once at startup. \n
                    2. @yearly: Run once a year. \n
                    3. @monthly: Run once a month. \n 
                    4. @weekly: Run once a week. \n 
                    5. @daily: Run once a day. \n 
                    6. @hourly: Run once an hour.  \n " pre_made
            
            case "$pre_made" in 
                "1") 
                    monkey="@reboot"
                    ;;
                "2") 
                    monkey="@yearly"
                    ;;
                "3") 
                    monkey="@monthly"
                    ;;
                "4") 
                    monkey="@weekly"
                    ;;
                "5") 
                    monkey="@daily"
                    ;;
                "6") 
                    monkey="@hourly"
                    ;;
                *)
                    echo "please provide the appropriate input."
                    exit 1
                    ;;
            esac
        *)
            echo "please provide a number between 1 and 2"
            exit 1
            ;;
    esac

    # Create the crontab entry
    local crontab_entry="$monkey bash $script_path"

    # Check if the crontab already has this entry
    crontab -l 2>/dev/null | grep -qF "$crontab_entry"
    
    if [ $? -eq 0 ]; then
        echo "The task is already in the crontab."
    else
        # Add the new task to the crontab
        (crontab -l 2>/dev/null; echo "$crontab_entry") | crontab -
        echo "The task has been added to the crontab."
    fi
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
