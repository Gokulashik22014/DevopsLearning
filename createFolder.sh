#! /bin/bash

read -p "Enter the folder name" name

rm -rf $name

mkdir $name

cd $name 

read -p "Enter the number of files" number

echo "num $number"

for((i=1;i<=number;i++))
do
	touch "file$i.txt"
done

pwd

ls -ltr

