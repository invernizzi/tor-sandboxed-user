#!/bin/bash
sudo apt-get install puppet-common
sudo puppet apply recipes/create_sandboxed_toruser.pp
