#!/bin/bash
#@(#) Checks if the VPN connection is up and refresh it if not

usage() {
	cat <<HELP_USAGE

	$0 -f Filename [-args]

	------------------------------------

	-f    Configuration file
	-u    URL to check the VPN connection
	-s    Seconds of timeout to check VPN connection [default 10]
	-o    Opens a connection directly without checking the connectiono [default false]
	-c    Closes the connection [default false]
	-t    Test connection and exit [default false]
	-h    Shows this help

	Example: $0 -f /home/VPN_files/vpn_configuration_file.ovpn -u https://gitlab.devotools.com/

HELP_USAGE
exit 1
}

check() {
    ret=$(curl $url --connect-timeout $timeout)
    if [[ -z "$ret" ]]
    then
        echo "VPN is down :(" 
        false
    else
        echo "VPN ok :)"
        true
    fi
}

close() {
    echo "Closing the VPN session..."
    openvpn3 sessions-list
    readarray -t OPENVPN3_SESSION_PATH < <(openvpn3 sessions-list | grep "Path" | cut -d':' -f2 | cut -d' ' -f2)
    if [[ ${#OPENVPN3_SESSION_PATH[@]} -eq 0 ]]; then
        echo "No opened sessions found"
    else
        for session_path in ${OPENVPN3_SESSION_PATH[@]}
        do
            echo "Closing session at $session_path"
            openvpn3 session-manage --session-path $session_path --disconnect
        done
    fi
}

open() {
    echo "Openning the VPN session..."
    echo "A firefox window will appear"
    browser=$(xdg-settings get default-web-browser)
    echo "Your default browser is $browser"
    # open vpn3 doesn't work on brave-browser so we need to use firefox instead
    xdg-settings set default-web-browser firefox.desktop
    fbrowser=$(xdg-settings get default-web-browser)
    if [[ $fbrowser != "firefox.desktop" ]]; then
        echo "ERROR can't set Firefox as default browser"
        fire=$(firefox -h)
        if [[ -z $a ]]; then
            echo "Firefox Browser is not installed"
            echo "Please install it as it is required for this script to work"
        fi
        exit 1
    fi

    openvpn3 session-start --config $file

    xdg-settings set default-web-browser $browser
    browser2=$(xdg-settings get default-web-browser)
    if [[ $browser != $browser2 ]]; then
        echo "Can't set your original browser that was $browser"
        echo "Default browser is set to $browser2"
    fi
}

# Main
skip=false
check=false
timeout=10
while getopts tochf:u:s: flag
do
    case "${flag}" in
        h) usage;;
        o) skip=true;;
        t) check=true;;
        c) close && exit 0;;
        f) file=${OPTARG};;
        u) url=${OPTARG};;
        s) timeout=${OPTARG};;
	esac
done

if [[ -z $file || -z $url ]];
then
    usage
fi

if $skip; then
    echo "Opening without checking"
    open
    exit 0
fi

if $check; then
    echo "Only checking"
    check
    exit 0
fi

if check; then
    echo "Nothing to do"
else
    open
fi
