#!/bin/bash

exec pidof xcape |xargs kill -9
xcape -e 'Super_L=Super_L|z'
# xcape -e 'Super_L=Alt_L|space'
