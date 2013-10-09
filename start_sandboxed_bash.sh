#!/bin/bash

function show_ip_in_env () {
    $@ wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
}


echo 'Switching to the sandbox. Note: startup might be slow if the Tor server has just been launched'
xhost + > /dev/null  # show graphics from the sanboxed users in your X server
set -e  # Fail if anything unexpected happens
echo 'Checking if Tor is available...'
sudo -H -u tor-user python ~tor-user/check_if_sandboxed_by_tor.py
# Show external ip
echo -n 'Your current IP is '
show_ip_in_env
echo -n 'Your current Tor IP is '
show_ip_in_env sudo -H -u tor-user
sudo -H -u tor-user bash


