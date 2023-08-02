#!/bin/bash

usage() {
    cat <<EOM
    Util to cherry pick lot of commits from one branch to another
    -h: shows this help
    -o: orig branch
    -d: dest branch
    -c: first commit (oldest) to cherry-pick
    -v: verbose mode
    Usage: $0
EOM
    exit 0
}


init() {
    verbose=0
    dry_run=0
    while getopts "ho:d:c:vt" flag; do
        case "${flag}" in
            h)
                usage
                ;;
            o)
                orig_branch=$OPTARG
                ;;
            d)
                dest_branch=$OPTARG
                ;;
            c)
                last_commit=$OPTARG
                ;;
            v)
                verbose=1
                ;;
        esac
    done
    git checkout $orig_branch
    first_commit=$(git log -1 --pretty=format:"%h")
    file=/tmp/commits.txt
    if [[ $verbose -eq 1 ]]; then
        echo "First commit $first_commit"
        echo "Last commit $last_commit"
    fi
}

read() {
    echo "Reading commits ..."
    echo $last_commit > $file
    git log --reverse $first_commit...$last_commit --pretty=format:"%h" >> $file
    if [[ $verbose -eq 1 ]]; then
        cat $file
    fi
}

pick() {
    echo "Picking commits ..."
    readarray myArr < /tmp/commits.txt

    git checkout $dest_branch

    fail=0
    for commit in "${myArr[@]}"
    do
        a=$(tr -dc '[[:print:]]' <<< "$commit")
        if [[ $fail -eq 1 ]]; then
            echo "Not cherry-picking [$a]"
            continue 1
        fi
        echo "Cherry-picking [$a]"
        git cherry-pick $a
        status=$(git status -s)
        if [ -n "$status" ]; then
            echo ""
            echo "There are unresolved conflicts"
            echo "The rebase must be execued manually"
            echo "Use \"git cherry-pick --abort\" to cancel current operation"
            echo "The list of commits are saved in $file"
            echo ""
            git status
            fail=1
        fi
    done
    if [[ $fail -eq 1 ]]; then
        exit 1
    fi
}


# Main program

[ $# -eq 0 ] && usage
init $@
read
pick