#!/bin/bash

while true; do
        # check if there is internet connection
        connection=$(ping -c 1 8.8.8.8) > ~/git_pull.txt 2>&1

        if [[ $connection ]];then 
            echo "cyber security check " > ~/git_pull.txt
            cd ~/Documents/cyber_security/ && git pull >> ~/git_pull.txt 2>&1
            echo "scripts check " >> ~/git_pull.txt
            cd ~/Documents/Scripts/ && git pull >> ~/git_pull.txt 2>&1
            break
        else 
            echo "there is no internet connection... waiting for 10 seconds" >> ~/git_pull.txt
            sleep 10
        fi 
done
