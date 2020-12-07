#!/bin/bash
#@(#) Adds every file that has main function to a Makefile.am

usage () {
	cat <<HELP_USAGE

	Adds every file that has main function to a Makefile.am

	$0  [-args]
	------------------------------------
	-h    Shows this help
	-f    Adds filetype to the ones added
	-a    Not use default filetypes set [.c, .cpp]
	-d    Dry-run
	-o    Defines output. Default uses Makefile.am
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

default_filetypes="\.c|\.cpp"
filetypes=""
filetypes_n=0
tmp_file=""
dry_run=0
output="Makefile.am"
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

programs=$(ack main | egrep "$filetypes" | cut -d "." -f1)
files=$(ack main | egrep "$filetypes" | cut -d ":" -f1)
parray=($programs)
farray=($files)

rm $output

if (($dry_run == 0));
then
	echo "bin_PROGRAMS = "$programs >> $output
	for index in ${!parray[@]}
	do
		echo "${parray[index]}_SOURCES = ${farray[index]}" >> $output
	done
else
	echo "Will add:"
	echo "$programs"
fi
