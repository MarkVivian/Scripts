#!/bin/bash

# checks if the bash script was run in sudo/admin.
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

echo "----------------------------------------------------------------------"
echo "the following apps will be installed throught the terminal :"
echo "1. docker and its configuration"
echo "2. fzf for searching for files"
echo "3. xclip for copying data from the terminal"
echo "4. meld for a graphical comparison interface."
echo "5. install sublime-text as a lighter vs code"
echo "6. install vs code"
echo "7. install flutter"
echo "8. install node js"
echo "9. install brave, chrome and opera"
echo "10. install open toolbox"

echo "---------------------------------------------------------------------"
echo ">>>>>>>>>>>>>>>>>>>installing fzf, xclip, meld<<<<<<<<<<<<<<<<<<<<<<<<"
apt install meld fzf xclip curl -y

echo "----------------------------------------------------------------------"
echo ">>>>>>>>>>>>>>the following will be installed in the donwloads folder.<<<<<<<<<<<<<<<<<<"
cd ~/Downloads

echo "----------------------------------------------------------------------"
echo "installing vs code"
# curl -0 <the name to identify the file in the directory> <link to the donwload link>
curl -o vscode.deb https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64

echo "----------------------------------------------------------------------"
echo "installing flutter"
curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz

echo "----------------------------------------------------------------------"
echo "installing node js"
curl -o node.tar.xz https://nodejs.org/dist/v18.17.1/node-v18.17.1-linux-x64.tar.xz

echo "----------------------------------------------------------------------"
echo "installing sublime text"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update
sudo apt-get install sublime-text

echo "----------------------------------------------------------------------"
echo "installing brave browser"
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser

echo "----------------------------------------------------------------------"
echo "installing free donwload manager"
curl -o downloadmanager.deb https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb

echo "----------------------------------------------------------------------"
echo "installing toolbox for intellij"
curl -o toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.0.2.16660.tar.gz?_ga=2.228157976.400342586.1692300471-1346637076.1692300471&_gl=1*o56whi*_ga*MTM0NjYzNzA3Ni4xNjkyMzAwNDcx*_ga_9J976DJZ68*MTY5MjMwMDQ3MS4xLjEuMTY5MjMwMDU5Mi4wLjAuMA..

echo "----------------------------------------------------------------------"
echo "installing opera borwser"
curl -o opera.deb https://download.opera.com/download/get/\?id\=62659\&location\=415\&nothanks\=yes\&sub\=marine\&utm_tryagain\=yes

echo "----------------------------------------------------------------------"
echo "installing chrome browser"
curl -o chrome.deb https://www.google.com/chrome/next-steps.html?brand=CHBD&statcb=0&installdataindex=empty&defaultbrowser=0#

echo "----------------------------------------------------------------------"
echo "install deb, extract gz and xz files to /opt/"
my_array=()
chmod +x *.sh
# loop through all the files in the directory.
for file in *; do
	# check if the file is of type deb, gz or xz and install them using the extractingFiles.sh script.
	if echo $file | grep deb; then
		# instead of me adding the input, this will bypass it and pass in 4 in my place.
		./extractingFiles.sh <<< 4 <<< $file
	else
		# add the item to my array/list.
		my_array+=("/opt/$file")
		elif echo $file | grep gz; then
			# this files are going to be extracted in the /opt/ folder.
			./extractingFiles.sh <<< 2 <<< $file <<< y <<< /opt/
		elif echo $file | grep xz; then
			./extractingFiles.sh <<< 1 <<< $file <<< y <<< /opt/
	 	fi
	 fi
	 # remove the file after installation or extraction
 	rm -r $file
done

echo "----------------------------------------------------------------------"
echo "adding all the programs in /opt/ to the bashrc path script"
cd ~
path_array=()
# loop through the my_array[], the @ tells it to loop through all its values and {} is very important.
for files in ${my_array[@]}; do
	# check if the directory exists.
	if [ -d $files/bin ]; then
		path_array+=("$files/bin/")
	fi
done
# store the array/list in a format where they are seperated by :/
printf -v array_line "%s:" "${path_array[@]}"
# add the paths to the bashrc file.
echo "export PATH=$PATH:$array_line" >> ~/.bashrc
#reload the bashrc .
source ~/.bashrc

echo "----------------------------------------------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>installing docker<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
apt install docker.io -y

active_checker=$(systemctl status docker | grep active | cut -d':' -f2 | cut -d' ' -f2)

if [[ $active_checker = "active" ]]; then
	echo "docker has been installed and is running."
	echo "docker status is $active_checker"
	docker_without_sudo=$(docker image ls | grep REPOSITORY | cut -d' ' -f1)
	
	if [[ $docker_without_sudo = "REPOSITORY" ]]; then
		echo "docker has been configured successfully"
	else
		usermod -aG docker $USER
		systemctl restart docker
		echo "please log out of the system and log back in to setup docker"
	fi

else
	echo "checker is empty"
	systemctl restart docker
	systemctl enable docker
fi



