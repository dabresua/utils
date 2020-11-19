#!/bin/bash
#@(#) Cleans folder and 1-level of subfolders

usage () {
	cat <<HELP_USAGE
	$0  [-args]
	------------------------------------
	-h    Shows this help
	-s    Source folder. Defaults assumes actual folder.
	-l    Not clean subfolders
	-d    Dry-run
HELP_USAGE
exit 1
}

clean_local() {
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

dry_run=0
only_locals=0
while getopts hs:dl flag
do
	case "${flag}" in
		h) usage;;
		l) only_locals=1;;
		d) dry_run=1;;
		s) source=${OPTARG};;
	esac
done

if [ -z $source ];
then
	source=$(pwd)
fi

cd $source
clean_local
subs=$(ls -d */)
echo $subs
for sub in $subs
do
	cd $sub
	clean_local
	cd ..
done
