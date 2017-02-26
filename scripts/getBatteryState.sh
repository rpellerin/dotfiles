#!/bin/bash

# Script used by tmux to display the battery percentage in colored text

# modified from https://github.com/tmux-plugins/tmux-battery
# inspired by https://github.com/nicknisi/dotfiles/blob/master/bin/battery_indicator.sh

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

charging_icon="🔌"

command_exists() {
	local command="$1"
	type "$command" >/dev/null 2>&1
}

print_battery_percentage() {
    if [[ `uname` == 'Linux' ]]; then
        if command_exists "pmset"; then
            pmset -g batt | awk 'NR==2 { gsub(/;/,""); print $2 }'
        elif command_exists "upower"; then
            for battery in $(upower -e | grep battery); do
                state=$(upower -i $battery | grep state | awk '{print $2}')
                percentage=$(upower -i $battery | grep percentage | awk '{print $2}' | awk '{print substr($0, 1, length($0)-1)}')
                if [ "$state" == 'charging' ] || [ "$state" == 'fully-charged' ]; then
                    echo -n "#[fg=colour82]$charging_icon "
                else
                    if [ "$percentage" -gt "50" ]; then
                        echo -n "#[fg=colour40]"
                    elif [ "$percentage" -gt "30" ]; then
                        echo -n "#[fg=colour190]"
                    else
                        echo -n "#[fg=colour1]"
                    fi
                fi
                echo -n "$percentage%"
            done | xargs echo
        elif command_exists "acpi"; then
            acpi -b | grep -Eo "[0-9]+%"
        else
            cat /proc/acpi/battery/BAT1/state | grep 'remaining capacity' | awk '{print $3}'
        fi
    else
        battery_info=`ioreg -rc AppleSmartBattery`
        echo -n $battery_info | grep -o '"CurrentCapacity" = [0-9]\+' | awk '{print $3}'
    fi
}

state="teub"
main() {
	print_battery_percentage
}
main
