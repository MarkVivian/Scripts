#!/bin/bash

read -p "please provide your email address that is linked to your github account:    " githubEmail

ssh-keygen -t ed25519 -C "$githubEmail" <<< $'\n'

echo "SSH key generated successfully."

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard

echo "please paste in the ssh part of github.. thank you"


