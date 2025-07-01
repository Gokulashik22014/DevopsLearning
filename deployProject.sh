#!/bin/bash

set -x

set -e

read -p "Enter naems" username reponame

cd projects

rm -rf $reponame

git clone "https://github.com/$username/$reponame.git"

cd $reponame

npm install 

npm run build

sudo npm install -g serve

serve -s build
