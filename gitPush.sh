#!/bin/bash

read -p "Enter your commit message : " CommitMessage
git add .
git commit -m "$CommitMessage"
# checks the current branch.. the $() allows us to use commands and store them in variables.
branch_name=$(git rev-parse --abbrev-ref HEAD)

echo "Pushing to branch: $branch_name..."
git push origin "$branch_name"
