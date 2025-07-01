#!/bin/bash

read -p "Enter the name of the folder" name

rm -rf $name

mkdir $name 

cd $name

count=3

for((i=1;i<=count;i++))
do
	cat<<EOF> "test$i.sh"
		echo "this is fun"
EOF
	chmod +x "test$i.sh"
done

ls -ltr

for((i=1;i<=count;i++))
do
	sh "test$i.sh"
done

