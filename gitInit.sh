#!/bin/bash

read -p "enter the url for the repository: " repo

git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin $repo
git push -u origin main
