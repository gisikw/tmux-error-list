#!/usr/bin/env bash

pipe=/tmp/tmux-error-list-pipe

if [[ "$1" ]]; then
  echo "$1" >$pipe
else
  echo >$pipe
fi
