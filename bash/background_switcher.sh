#!/bin/bash

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


while true; do
    sleep 10

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

    # check which desktop environment your running.
    # todo : not working .. its not detecting desktop env
    desktop_env=$(echo $XDG_CURRENT_DESKTOP) # doesn't work because cron cannot detect the environment.
    
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

    # Wait 10 minutes before changing the wallpaper again.
    sleep 600
done
