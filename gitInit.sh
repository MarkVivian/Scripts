#!/bin/bash

read -p "enter the url for the repository: " repo
git init
git add .
git remote add origin $repo
git push -u origin main
