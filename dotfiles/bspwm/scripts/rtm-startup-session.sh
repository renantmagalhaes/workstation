#!/bin/bash

bspc desktop --focus 1 ; vivaldi &
sleep 2
bspc desktop --focus 11 ; vivaldi  &
vivaldi https://youtube.com &
sleep 2
bspc desktop --focus 2 ; /opt/vivaldi/vivaldi --profile-directory=Default --app-id=hnpfjngllnobngcgfapefoaidbinmjnm &
sleep 1
bspc desktop --focus 22 ; /opt/vivaldi/vivaldi --profile-directory=Default --app-id=aeejceomnhmjmeacdckmmopfaigimnkl &
sleep 0.5
bspc desktop --focus 5
vivaldi --args --incognito &
sleep 0.5
bspc desktop --focus 11 && bspc desktop --focus 1