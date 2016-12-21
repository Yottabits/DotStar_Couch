#!/bin/bash

RED='\033[0;31m'
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LIGHTBLUE='\033[1;34m'
LIGHTCYAN='\033[1;36m'
NOCOLOR='\033[0m' # No Color

BRANCH='stable'

function status_update() {
    echo -e "\n${LIGHTBLUE}$@${NOCOLOR}"
}

function msg_error() {
    echo -e "\n${LIGHTRED}$@${NOCOLOR}"
}

function msg_success() {
    echo -e "\n${GREEN}$@${NOCOLOR}"
}

function question() {
    echo -en "${LIGHTCYAN}$@${NOCOLOR}"
}

function install()
{
    status_update " => Getting the latest stable release from GitHub"
    git clone -b ${BRANCH} https://github.com/Yottabits/102shows.git
    rc=$?; if [[ ${rc} == 0 ]]; then   # check for success
        msg_success " => Download finished! (return code: $rc)"
    else
        msg_error " => Download failed! (return code: $rc)"
        msg_error "    Exiting installation!"
        exit ${rc}
    fi


    cd 102shows

    rm ./server/setup.sh  # remove this installer

    status_update " => Installing requirements..."
    pip3 install -r ./requirements.txt
    rc=$?; if [[ ${rc} == 0 ]]; then   # check for success
        msg_success " => Requirements are ready! (return code: $rc)"
    else
        msg_error " => Requirements installation failed! (return code: $rc)"
        msg_error "    Maybe You do not have sufficient rights - try running this script with sudo..."
        msg_error "    For now I am going to quit the installation."
        exit ${rc}
    fi

    echo -e  "$(cat logo)  version: $(cat version)"
    echo -e "\n\n"

    question " => Would you like to configure 102shows now? [Y/n]  "
    read answer
    if [ "$answer" != "n" ] && [ "$answer" != "N" ]; then
        status_update " => copying config.example.yml to config.yml"
        cp ./server/config.example.yml ./server/config.yml
        status_update " => starting editor..."
        editor ./server/config.yml
    else
        msg_error " => Before you can start the 102shows server,"
        msg_error "    you must provide a valid configuration file"
        msg_error "    in \"102shows/server/config.yml\""
    fi

    msg_success "
 => We successfully installed the 102shows server :-)
      - Note that you need to an MQTT broker in order for the server to work
      - If you wan t to use the included UI, you should install it now
        You can find the instructions at https://git.io/v1x5Os
      - To run the server, cd in $PWD/server and execute \"python3 server.py\"
    "
}

function main()
{
    question " => Would you like to install 102shows to $PWD/102shows? [y/N]  "
    read answer
    if [ "$answer" == "y" ] || [ "$answer" == "Y" ]
    then
        install
    fi

}

main