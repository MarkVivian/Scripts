#!/bin/bash

# the -p allows us to pass a prompt message to the user.
read -p "Enter your commit message : " CommitMessage

git add .
git commit -m "$CommitMessage"
git push
