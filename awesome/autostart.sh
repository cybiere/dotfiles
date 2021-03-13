#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}
xbacklight = 20%
run picom
run autorandr --change
run nm-applet
run cbatticon
run unclutter -idle 3 -root
run pasystray
