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
  ;;
lock|unlock)
  if [[ -z "$2" ]]
  then
    echo "Specify a unit to unlock"
    exit -1
  else
    lock_id=$(getdevices | jq ".[] | select(.name==\"$2\")" | jq -r ".id")

    curl -X PUT -s "$API_URL/locks/$lock_id?access_token=$ACCESS_TOKEN&state=$1"
  fi
  ;;
esac
