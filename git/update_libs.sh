#!/bin/bash
#@(#) Updates libraries on a project
# libraries always starts with the prefix "lib"
# -i to make install those libraries

usage () {
	cat <<HELP_USAGE
	$0  [-args]
	------------------------------------
	-h  Shows this help
	-i  Install libraries (make install)
HELP_USAGE
exit 1
}

while getopts hi flag
do
	case "${flag}" in
		h) usage;;
		i) inst=1;;
	esac
done

libs=$(ls -l | grep ^d | grep lib | rev | cut -d" " -f1 | rev)
n=$(ls -l | grep ^d | grep lib -c)

if [ $n -eq 0 ];
then
	echo "No libraries found"
	exit 1
fi

echo "Updating the following libraries:"
echo "\033[35m$libs\033[0m"
for i in $(seq 1 1 $n)
do
	folder=$(echo $libs | cut -d" " -f$i)
	cd $folder
	git pull
	if [ $inst -eq 1 ]:
	then
		make install
	fi
	cd ..
done
