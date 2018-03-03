#!/usr/bin/env bash

pipe=/tmp/tmux-error-list-pipe
file=/tmp/tmux-error-list-file
trap "rm -f $pipe" EXIT 
# See if possible to remove error_pane if exists?

if [[ ! -p $pipe ]]; then
  mkfifo $pipe
fi

state="invisible"
error_pane=""
while true; do
  echo $state
  message=$(cat $pipe)
  if [[ -z "$message" ]]; then
    state="invisible"
    if [[ ! -z "$error_pane" ]]; then
      tmux kill-pane -t $error_pane
    fi
    error_pane=""
  else
    state="visible"
    if [[ ! -z "$error_pane" ]]; then
      tmux kill-pane -t $error_pane
    fi
    echo -n "$message" > $file
    len=$(($(wc -l < $file)+1))
    tmux split-window -l $len "cat $file; cat"
    error_pane=$(tmux list-panes | grep '(active)' | cut -d ':' -f 1)
    tmux last-pane
  fi
done
