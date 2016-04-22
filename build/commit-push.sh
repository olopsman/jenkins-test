#!/bin/bash
# set the origin remote to our repo url
gitremote=`git remote -v`
if [[ -z $gitremote ]]; then
	git remote add origin $repourl
elif [[ $gitremote == *nothing* ]]; then
	git remote set-url origin $repourl
fi

# set up git user 
if [[ -z $bamboouser ]]; then
    bamboouser="Atlassian Bamboo"
fi

git config user.name $bamboouser
git config user.email $bambooemail
    
# add, commit and push changes
filelist=`git status -s`
if [[ -n $filelist ]]; then
	echo "File list $filelist"
	echo "Adding files"
  	git add src/*
	echo "Committing"
  	git commit -a -m "$commitmsg"
	echo "Push"
 	returnval=`git push origin $branchname`
	echo "Push result $returnval"
 	if [[ -z $returnval ]]; then 
 		exit 0;
 	else
 		exit 1;
 	fi
else 
	echo '**** Nothing to commit ****'
	exit 1
fi