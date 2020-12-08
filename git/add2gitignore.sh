#!/bin/bash
#@(#) Adds non-desired files to a .gitignore. Use it for adding binaries after compilation

usage () {
	cat <<HELP_USAGE

	Adds non-desired files to a .gitignore. Use it for adding binaries after compilation
	
	$0  [-args]
	------------------------------------
	-h    Shows this help
	-f    Adds filetype to the ones that are not added
	-a    Not use default filetypes set [.c, .h, .cpp, .java, .py, .md, .sh, .am, .gitignore]
	-d    Dry-run
	-o    Defines output. Default uses .gitgnore
HELP_USAGE
exit 1
}

push_filetype() {
	if (($filetypes_n == 0));
	then
		filetypes="\.$tmp_file"
	else
		filetypes=$(echo "$filetypes|\.$tmp_file")
	fi
	filetypes_n=$(($filetypes_n+1))
}

default_filetypes="\.c|\.h|\.cpp|\.java|\.py|\.md|\.sh|\.am|\.gitignore"
filetypes=""
filetypes_n=0
tmp_file=""
dry_run=0
output=".gitignore"
while getopts hf:dao: flag
do
	case "${flag}" in
		h) usage;;
		a) default_filetypes="";;
		d) dry_run=1;;
		f) tmp_file=${OPTARG} && push_filetype;;
		o) output=${OPTARG}
	esac
done

[[ -n $default_filetypes ]] && tmp_file=$default_filetypes && push_filetype

#echo "filetypes not added to .gitignore: $filetypes"

non_follow=$(git status -s | egrep -v "$filetypes" | rev | cut -d" " -f1 | rev)

if (($dry_run == 0));
then
	[[ -n $non_follow ]] && echo "$non_follow" >> $output
else
	echo "Will add:"
	echo "$non_follow"
fi
