#!/bin/bash

read -p "enter the userName " userName
read -p "enter the email" email

git config --global user.name "$userName"
git config --global user.email "$email"

git config --list
