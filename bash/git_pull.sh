#!/bin/bash

# it will sleep for 2 minutes.
sleep 120 

cd ~/Documents/cyber_security/ && git pull > ~/cyber_git_pull.txt 2>&1
cd ~/Documents/Scripts/ && git pull > ~/Scripts_git_pull.txt 2>&1
