
#!/bin/bash

export DISPLAY=:0.0
export XAUTHORITY=/home/mark/.Xauthority
export PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native


battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

# logging the script.
logfile="/var/log/script_logs/battery_alert.log"
touch $logfile
chmod 755 $logfile

# Redirect stdout and stderr.
exec &> "$logfile"

	# alert if battery drops below 30 when not charging
if [ "$battery_status" != "Charging" ]; then

	if [ "$battery_percentage" -le 30 ]; then
		echo "battery run low at $(date)"
		notify-send -u critical "Battery Low" "battery percentage below 30 percent. Please Recharge";
		paplay /usr/share/sounds/freedesktop/stereo/message.oga
	fi

fi

# alert if battery is full while charging.
if [ "$battery_status" == "Full" ]; then 
	
	echo "battery fully charged at $(date)"
	notify-send -u critical "Battery full" "battery fully charged. Please remove charger."
	paplay /usr/share/sounds/freedesktop/stereo/complete.oga
fi