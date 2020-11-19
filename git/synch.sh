#!/bin/bash
#@(#) Synchronizes two git folders of the same repo without pushing or commit

usage () {
	cat <<HELP_USAGE
	$0 -d dest [-args]
	------------------------------------
	-d    Destination folder
	-s    Source folder. Defaults assumes actual folder.
	-c    Only check (Dry run)
	-h    Shows this help
HELP_USAGE
exit 1
}

clear_local() {
	if [ $dry_run -gt 0 ];
	then
		non_added=$(git status -s | egrep "A |AM| M" | rev | cut -d" " -f1 | rev)
		non_follow=$(git status -s | egrep "??" | rev | cut -d" " -f1 | rev)
		echo "Will clean "
		echo "$non_added"
		echo "$non_follow"
	else
		git checkout .
		non_follow=$(git status -s | egrep "??" | rev | cut -d" " -f1 | rev)
		rm $non_follow
	fi
}

synch_dry() {
	to_copy=$(git status -s | egrep "M|A|AM|??" | rev | cut -d" " -f1 | rev)
	echo "Will copy $to_copy"
}

synch_local() {
	if [ $dry_run -gt 0 ];
	then
		to_copy=$(git status -s | egrep "M|A|AM|??" | rev | cut -d" " -f1 | rev)
		echo "Will copy $to_copy"
	else
		to_copy=$(git status -s | egrep "M|A|AM|??" | rev | cut -d" " -f1 | rev)
		cp --parents $to_copy $2
	fi
}

dry_run=0
while getopts hs:d:c flag
do
	case "${flag}" in
		h) usage;;
		s) source=${OPTARG};;
		d) dest=${OPTARG};;
		c) dry_run=1
	esac
done

if [ -z $dest ];
then
	usage
fi

if [ -z $source ];
then
	source=$(pwd)
fi

cd $dest && clear_local
cd $source && synch_local
