#!/bin/bash

# Installation
sudo zypper install -y virtualbox
sudo usermod -a -G vboxusers $USER
newgrp vboxusers