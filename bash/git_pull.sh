#!/bin/bash

# todo : add functionality to check if there is internet connection.

# it will sleep for 3 minutes.
sleep 180 

cd ~/Documents/cyber_security/ && git pull > ~/cyber_git_pull.txt 2>&1
cd ~/Documents/Scripts/ && git pull > ~/Scripts_git_pull.txt 2>&1
