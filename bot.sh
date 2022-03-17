#!/bin/bash
#
# This script handles your Discord Bots (only python!) 

bots=("your" "bots" "here")           # list of bots for "all" case !!! NO FILE-ENDINGS !!!
arg_length="${#}"                   # length of cli arguments
target="${2}"                       # target which should be handled
method="${1}"                       # method to handle $target

BOT_DIR="/path/where/your/bots/are/located"     # Directory where the bots are located (WITHOUT / at the end!)

#######################################
#        starting specific bots       #
#######################################
function start {
    if [[ $(dpkg -l | grep -c python3) -gt 0 ]]; then
        if [[ "${1}" != "all" ]]; then
            local bot="${1}"
            if [[ -f "${BOT_DIR}"/"${bot}".py ]]; then
                if [[ $(screen -ls | grep -c "${bot}") -eq 0 ]]; then
                    screen -dmS "${bot}" python3 "${BOT_DIR}"/"${bot}".py
                    echo "started ${bot}"
                else
                    echo "${bot} is already running"
                fi
            else 
                echo "${bot} was not found!"
            fi
            return 0 
        fi
        for bot in "${bots[@]}"
        do
            if [[ -f "${BOT_DIR}"/"${bot}".py ]]; then
                if [[ $(screen -ls | grep -c "${bot}") -eq 0 ]]; then
                    screen -dmS "${bot}" python3 "${BOT_DIR}"/"${bot}".py
                    echo "started ${bot}"
                else
                    echo "${bot} is already running"
                fi
            else 
                echo "${bot} was not found!"
            fi
        done
        echo "all bots started."
    else
        echo "python3 is not installed!"
    fi
}

#######################################
#        stopping specific bots       #
#######################################
function stop {
    if [[ "${1}" != "all" ]]; then
        local bot="${1}"
        if [[ -f "${BOT_DIR}"/"${bot}".py ]]; then
            if [[ $(screen -ls | grep -c "${bot}") -gt 0 ]]; then
                screen -XS "${bot}" quit
                echo "stopped ${bot}"
            else
                echo "${bot} is not running"
            fi
        else 
            echo "${bot} was not found!"
        fi
        return 0
    fi
    for bot in "${bots[@]}"
    do
        if [[ $(screen -ls | grep -c "${bot}") -gt 0 ]]; then
            screen -XS "${bot}" quit
            echo "stopped ${bot}"
        else
            echo "${bot} is not running"
        fi
    done
    echo "all bots stopped!"
    return 0
}

#######################################
#       listing all running bots      #
#######################################
function list {
    output=$(for bot in "${bots[@]}"; do if [[ $(screen -ls | grep -c "${bot}") -gt 0 ]]; then echo "${bot}"; fi done)
    if [[ ${output} == "" ]]; then
        echo "all bots are currently stopped"
        return 0
    fi
    echo "${output}"
    return 0
}

#######################################
#  displaying the help page (--help)  #
#######################################
function displayHelp {
    echo '<------------------------------------------>'
    echo 'dc-bot [action] <target>'
    echo '<-----------------[actions]---------------->'
    echo '--start) -  Starting the bots'
    echo '--stop)  -  Stopping the bots'
    echo '--help)  -  Shows this Page'
    echo '<-----------------<target>----------------->'
    echo 'all)     -  manage all bots in bots array'
    echo '<bot>)   -  manage a specific bot'
    echo '<------------------------------------------>'
    return 0
}

#######################################
#        handling the execution       #
#######################################
function handleExec {
    if [[ "${method}" -ne "" ]]; then
        case "${method}" in
        --start)
            if [[ "${target}" = "all" && "${arg_length}" -eq 2 ]]; then
                start all || return 1
            elif [[ "${arg_length}" -eq 2 ]]; then
                start "${target}" || return 1
            else
                echo "not enough arguments! use --help"
            fi
            ;;
        --stop)
            if [[ "${target}" = "all" && "${arg_length}" -eq 2 ]]; then
                stop all || return 1
            elif [[ "${arg_length}" -eq 2 ]]; then
                stop "${target}" || return 1
            else 
                echo "not enough arguments! use --help"
            fi
            ;;
        --help)
            displayHelp || return 1
            ;;
        --list)
            list || return 1
            ;;
        *) 
            echo "Invalid Option ${method}! use --help"
        esac
    else
        echo "please specify an Method! use --help"
    fi
}

handleExec || return 1
