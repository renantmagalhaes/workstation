#!/bin/bash

systemctl --user unmask plasma-kwin_x11.service

systemctl --user disable plasma-custom-wm.service
