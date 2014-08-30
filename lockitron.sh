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

getlockid() {
  getdevices | jq ".[] | select(.name==\"$1\")" | jq -r ".id"
}

case $1 in
list)
  all_devices=$(getdevices)
  echo $all_devices | jq -r ".[].name"
  ;;
status)
  if [[ -z "$2" ]]
  then
    echo "Specify a unit to retrieve the status"
    exit -1
  else
    lock_id=$(getlockid "$2")

    status=$(curl -s "$API_URL/locks/$lock_id?access_token=$ACCESS_TOKEN" | jq '{state,avr_update_progress,ble_update_progress,pending_activity,updated_at,next_wake}')
    lock_state=$(echo $status | jq -r '.state')
    next_wake_utc=$(echo $status | jq -r '.next_wake')
    next_wake=$(date -d "$next_wake_utc")
    last_update_utc=$(echo $status | jq -r '.updated_at')
    last_update=$(date -d "$last_update_utc")
    echo "State of lock \"$2\"
State:		$lock_state
Last Updated:	$last_update
Next Update:	$next_wake
"
  fi
  ;;
lock|unlock)
  if [[ -z "$2" ]]
  then
    echo "Specify a unit to $1"
    exit -1
  else
    lock_id=$(getlockid "$2")

    curl -X PUT -s "$API_URL/locks/$lock_id?access_token=$ACCESS_TOKEN&state=$1"
  fi
  ;;
firmware)
  if [[ -z "$2" ]]
  then
    echo "Specify a unit to update firmware on"
    exit -1
  else
    lock_id=$(getlockid "$2")

    curl -X PUT -s "$API_URL/locks/$lock_id?access_token=$ACCESS_TOKEN&update_avr_firmware=true&update_ble_firmware=true"
  fi
  ;;
esac
