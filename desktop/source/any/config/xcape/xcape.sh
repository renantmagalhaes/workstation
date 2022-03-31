#!/bin/bash

exec pidof xcape |xargs kill -9
xcape -e 'Super_L=Super_L|z'
