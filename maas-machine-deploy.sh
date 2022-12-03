#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt install lm-sensors -y

sudo mkdir -p /storage_raid/lxd

sudo shutdown -r now