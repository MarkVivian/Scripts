#!/bin/bash

read -p "enter the url for the repository: " repo

git_creation(){
    git init
    git add README.md
    git commit -m "first commit"
    git branch -M main
    git remote add origin $repo
    git push -u origin main 
}

git_creation
# run_commands 2>&1: This runs the run_commands function and captures both stdout and stderr in a single stream.
# $(run_commands 2>&1): The $(...) syntax is command substitution, which captures the output of the enclosed command (in this case, the run_commands function).
# == *"expected_error_message"*: This checks if the captured output contains the specified error message.
if [[ $(git_creation 2>&1) == *"remote: Support for password authentication"* ]];
then
    echo "Handling the specific error message: SSH key setup required."
    read -p "enter your github email " githubEmail
    # -N "": Specifies an empty passphrase.
    # -q: Suppresses informational messages.
    # Run ssh-keygen to create the key
    keygen_output=$(ssh-keygen -t ed25519 -C "$githubEmail" -N "" -q) 

    # Extract the filename from the keygen output
    key_filename=$(echo "$keygen_output" | grep -oE '(/[^ ]+)+')

    eval "$(ssh-agent -s)"

    # Add the key to the SSH agent
    ssh-add "$key_filename" 

    echo "now copy the .ssh key in the ~/.ssh/ and add it to github"
fi