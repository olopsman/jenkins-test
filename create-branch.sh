#!/bin/bash
# set the origin remote to our repo url
gitremote=`git remote -v`
if [[ -z $gitremote ]]; then
	git remote add origin $repourl
elif [[ $gitremote == *nothing* ]]; then
	git remote set-url origin $repourl
fi

# create branches for $name activities
echo "Creating branch $name"
git branch $name
git push origin $name
