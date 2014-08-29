#!/bin/bash

if [[ -z "$CONFIG" ]]
then
  CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/lockitron
fi

API_URL=https://api.lockitron.com/v2

source $CONFIG

getdevices() {
  curl -s "$API_URL/locks?access_token=$ACCESS_TOKEN" | jq "[.[] | {name,id}]"
}

case $1 in
list)
  all_devices=$(getdevices)
  echo $all_devices | jq -r ".[].name"
esac
