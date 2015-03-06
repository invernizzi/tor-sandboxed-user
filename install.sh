#!/bin/bash
sudo apt-get install -y puppet-common
# For GUIs, also install
# x11-xserver-utils
sudo puppet apply recipes/create_sandboxed_toruser.pp
sudo service tor restart
