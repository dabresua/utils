#!/bin/bash
#@(#) Example of arguments into a bash script

echo "Total Arguments:" $#
echo "All Arguments values:" $@

for i in $@
do
	echo $i
done

while getopts u:a:f: flag
do
	case "${flag}" in
		u) username=${OPTARG};;
		a) age=${OPTARG};;
		f) fullname=${OPTARG};;
	esac
done

echo "username $username"
echo "age $age"
echo "fullname $fullname"
