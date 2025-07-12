#!/bin/bash

# ensure to change this exports to your linux user settings.
export DISPLAY=:0.0
export XAUTHORITY=/home/mark/.Xauthority
export PULSE_SERVER=unix:/run/user/$(id -u)/pulse/native    
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# if you use an echo above the log exec in line 17 it will apear in journalctl -u service_name
# logging the script.
logfile="/var/log/script_logs/background_switcher.log"
touch $logfile
chmod 755 $logfile

# Get all the images from directory ~/Pictures/cars
# The external () stores the images in an array.
pic_location="$HOME/Pictures/cars"
walpapers=($(ls $pic_location))

# Redirect stdout and stderr.
exec &> "$logfile"
echo "Script started at $(date)"

# Initialize the previous number with a value that cannot match any valid index (e.g., -1).
previousNumber=-1

check_wallpaper_tools() {
    local missing=()

    # Check for xwallpaper
    if ! command -v xwallpaper >/dev/null; then
        echo "$(date): xwallpaper is not installed." 
        missing+=("xwallpaper")
    fi

    # Check for feh
    if ! command -v feh >/dev/null; then
        echo "$(date): feh is not installed."
        missing+=("feh")
    fi

    # If none are missing, return
    if [ ${#missing[@]} -eq 0 ]; then
        echo "All wallpaper tools are installed."
        return
    fi

    # Build install command
    install_cmd="sudo apt install -y ${missing[*]}"

    # Use Zenity if available
    if command -v zenity >/dev/null; then
        zenity --error \
            --title="Missing Packages" \
            --width=300 \
            --text="The following tools are missing:\n${missing[*]}\n\n please install them"
        exit 1
    fi
}

check_wallpaper_tools

IncaseVerticalMonitor() {

    local tmp_wallpaper="/tmp/vertical_wallpaper.jpg"
    local set_walpaper=$1

    # Function to set wallpaper for GNOME
    set_gnome_wallpaper() {
        gsettings set org.gnome.desktop.background picture-uri "file://$set_walpaper"
        gsettings set org.gnome.desktop.background picture-options 'zoom'
    }

    # Function to set wallpaper for MATE
    set_mate_wallpaper() {
        gsettings set org.mate.background picture-filename "$set_walpaper"
        gsettings set org.mate.background picture-options 'zoom'
    }

    # Function to set wallpaper for XFCE
    set_xfce_wallpaper() {
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$set_walpaper"
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 3  # 3 is for "Scaled"
    }

    # Function to set wallpaper for KDE
    set_kde_wallpaper() {
        # KDE Plasma needs a custom command for setting wallpaper style to "fit"
        # This assumes you have `plasma-apply-wallpaperimage` installed
        plasma-apply-wallpaperimage "$set_walpaper"
        # Set the wallpaper style to fit
        kwriteconfig5 --file plasmashellrc --group Wallpaper --key ImageScaling 2  # 2 is for "Stretch"
        kquitapp5 plasmashell && kstart5 plasmashell  # Restart plasmashell to apply changes
    }
    
    # check if there is an external monitor connected and if it is vertical.
    if xrandr | grep -q " connected"; then
        # check if there is a rotated monitor in parrot os...
        connected_monitors=$(xrandr | grep "connected" | grep -v "HDMI" | grep "left (" || grep "right (")

        # get the monitor name from xrandr.
        if [[ ! -z "$connected_monitors" ]]; then
            echo "External monitor is vertical, adjusting wallpaper settings."

            # example of text being cut.
            # DP-2 connected 1080x1920+0+0 left (normal left inverted right x axis y axis) 0mm x 0mm
            con_monitor_name=$(echo $connected_monitors | cut -d " " -f 1)

            img_height=$(identify -format "%h" "$set_walpaper")
            img_width=$(identify -format "%w" "$set_walpaper")

            if [[ $img_width -gt $img_height ]]; then
                echo "Image is wider ($img_width) than it is tall ($img_height), rotating wallpaper."
                # if vertical monitor rotate the wallpaper to fit the vertical monitor.
                convert "$set_walpaper" -rotate 90 "$tmp_wallpaper"
            fi
            gsettings set org.mate.background show-desktop-icons false
            killall caja
            xwallpaper --zoom $set_walpaper
            xwallpaper --output $con_monitor_name --zoom "$tmp_wallpaper"

            # just in case you want the icons back on your desktop.
            # gsettings set org.mate.background show-desktop-icons true
        else
            echo "No vertical external monitor detected, using default wallpaper settings."
            # check which desktop environment your running.
            desktop_env="MATE" # $(echo $XDG_CURRENT_DESKTOP) # doesn't work because cron cannot detect the environment.
            case "$desktop_env" in
                "GNOME")
                    echo "Detected GNOME, setting walpaper $set_walpaper..."
                    set_gnome_wallpaper
                    ;;
                "MATE")
                    echo "Detected MATE, setting walpaper $set_walpaper..."
                    set_mate_wallpaper
                    ;;
                "XFCE")
                    echo "Detected XFCE, setting walpaper $set_walpaper..."
                    set_xfce_wallpaper
                    ;;
                "KDE")
                    echo "Detected KDE, setting walpaper $set_walpaper..."
                    set_kde_wallpaper
                    ;;
                *)
                    echo "Unknown or unsupported desktop environment: $desktop_env"
                    echo "Trying all methods..."
                    set_gnome_wallpaper 2>/dev/null
                    set_mate_wallpaper 2>/dev/null
                    set_xfce_wallpaper 2>/dev/null
                    set_kde_wallpaper 2>/dev/null
                    ;;
            esac
                    
        fi
    
        notify-send "background change" "the background has been changed successfully"
    fi
}

while true; do

    # Get the number of images in the walpapers so that any update to the images folder is tracked.
    NumberOfWalpapers=${#walpapers[@]}

    # Get a random number between 0 and (NumberOfWalpapers - 1)
    RandomNumber=$(( RANDOM % NumberOfWalpapers ))

    # makes sure the same number is not picked twice at random.
    while [[ $RandomNumber -eq $previousNumber ]]; do
        RandomNumber=$(( RANDOM % NumberOfWalpapers ))
    done

    # Update previousNumber with the current random number.
    previousNumber=$RandomNumber

    # Set the wallpaper.
    set_walpaper="$pic_location/${walpapers[$RandomNumber]}"
    echo "Setting walpaper to: $set_walpaper"

    IncaseVerticalMonitor $set_walpaper

    # Wait 5 minutes before changing the wallpaper again.
    sleep 300
done
