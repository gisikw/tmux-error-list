#!/usr/bin/env bash

IFS=""

runner_pane=""

function show_error() {
  len=$1
  tmux split-window -l $len "cat /tmp/tmux-elm-log.txt; cat"
  runner_pane=$(tmux list-panes | grep '(active)' | cut -d ':' -f 1)
  tmux last-pane
}

function hide_error() {
  tmux kill-pane -t $runner_pane
  runner_pane=""
}

function parser() {
  state="listening"
  err=""
  while read -r line; do
    case "$state" in
      "listening")
        if [[ "$line" = *"---"* ]]; then
          echo "Good -> Error"
          err="$line"
          state="readingError"
        fi
        ;;
      "readingError")
        err="$err\n$line"
        if [[ "$line" = *"Detected errors in"* ]]; then
          len=$(echo -e "$err" | wc -l)
          echo -en $err > /tmp/tmux-elm-log.txt
          show_error $len
          echo "Error -> Bad"
          state="awaitingFix"
        fi
        ;;
      "awaitingFix")
        if [[ "$line" = *"Success!"* ]]; then
          hide_error
          state="listening"
          echo "Bad -> Good"
        elif [[ "$line" = *"---"* ]]; then
          echo "Bad -> Error"
          hide_error
          err="$line"
          state="readingError"
        fi
        ;;
    esac
  done
}

script -qF /dev/null elm-live example.elm --output example.js | parser
