#!/bin/bash

echo "what feature would you like to implement? "
echo "1) create new branch"
echo "2) remove branch"
echo "3) join branch with main"
echo "4) switch branches"

read -p "what option do you choose: " userChoice
read -p "enter the branch name: " branch_name

case $userChoice in
	1)
		git checkout -b $branch_name
		echo "Creating a new branch using command"
		echo "git checkout -b $branch_name"
		;;
	3)
		git checkout main
		git merge $branch_name
		echo "Conjoining (Merging) with the main branch using command"
		echo "git merge $branch_name"
		;;
	4)
		git checkout $branch_name
		echo "Switching branches using the command"
		echo "git checkout branch"
		;;
	2)
		git branch -d $branch_name
		echo "Deleting a branch using the command"
		echo "git branch -d $branch_name "
		# Add your commands for deleting a branch
		;;
	*)
		echo "Invalid choice. Please enter a valid option."
		;;
esac
