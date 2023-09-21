#!/bin/bash

echo "what do you wish to happen to the file: -"
echo "1) sort file and remove repeating words"
echo "2) compare two files"

read -p "choose your option:  " fileFormat

if [[ $fileFormat -eq 1 ]];then
	read -p "enter file path: " filePath
elif [[ $fileFormat -eq 2 ]];then
		read -p "enter file path for file1: " fileName1
		read -p "enter file path for file2: " fileName2
fi


filePath="/home/$USER/$filePath"
fileName1="/home/$USER/$fileName1"
fileName2="/home/$USER/$fileName2"


sortAndRemoveSimilarWords () {
	echo "the file is $filePath"
	# the -u will lead to only unique values.
	cat $filePath | sort -u > $filePath"sorted"
	rm -r $filePath
	cat $filePath"sorted" > $filePath
	rm -r $filePath"sorted"
}

compareTwoFiles () {
	sudo apt install diff
	echo "the following are the differences between the files."
	diff $fileName1 $fileName2
}

if [[ $fileFormat -eq 1 ]];then
	sortAndRemoveSimilarWords
elif [[ $fileFormat -eq 2 ]];then
	compareTwoFiles
else
	echo "invalid values has been provided."
fi

