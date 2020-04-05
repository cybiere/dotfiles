#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}
xbacklight = 20%
run autorandr --change
run blueman-applet
xrdb ~/.Xresources
unclutter -idle 3 -root
sleep 5
/home/ncnd/.apps/nextcloud.appimage
