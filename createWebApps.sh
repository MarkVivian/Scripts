#!/bin/bash
echo "do you wish to: "
echo "1) Create a React App"
echo "2) Create a Next App"
echo "3) Create a Node js App"
read -p "Enter your choice 1 , 2 or 3:  " choice

if [[ $choice -eq 1 ]]; then
    npm create vite@latest
    # Add your desired actions for choice 1 here
elif [[ $choice -eq 2 ]]; then
    npx create-next-app
elif [[ $choice -eq 3 ]]; then
    npm init
else
    echo "Invalid choice. Please enter either 1, 2 or 3."
fi

