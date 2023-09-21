#!/bin/bash

echo "what kind of file are you extracting: "
echo "1) tar.xz"
echo "2) tar.gz"
echo "3) .zip"
echo "4) install .deb file"
read -p "choose one of the following: " type
read -p "what is the file name: " filename

if [[ $type -eq 4 ]]; then
	echo "dpkg -i $filename"
	dpkg -i $filename
	break
else
	read -p "do you wish to change the directory where the file will be stored: (y or n)" choice
fi

if [[ $choice = "y" ]]; then
	read -p "please pass the path to the file: eg /path/to/location:    " location
else
	location="."
fi

if [[ $type -eq 1 ]]; then
		echo "tar -xf $filename -C $location"
		tar -xf $filename -C $location
	elif [[ type -eq 2 ]]; then
		echo "tar -xzf $filename -C $location"
		tar -xzf $filename -C $location
	else
		echo "unzip $filename -d $location"
		unzip $filename -d $location
fi
