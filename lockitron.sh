#!/bin/bash

if [[ -z "$CONFIG" ]]
then
  CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/lockitron
fi

API_URL=https://api.lockitron.com/v2

source $CONFIG

getdevices() {
  curl -s "$API_URL/locks?access_token=$ACCESS_TOKEN" | jq "[.[] | {name,id,hardware_id}]"
}

getlockid() {
  getdevices | jq ".[] | select(.name==\"$1\")" | jq -r ".id"
}

getlockhwid() {
  getdevices | jq ".[] | select(.name==\"$1\")" | jq -r ".hardware_id" | grep -o -E "[0-9a-fA-F]{8}$"
}

findlockbleaddr() {
  DEVS=$(hcitool lescan & (sleep 2 ; pkill --signal SIGINT hcitool))
  REGEX="([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}"
  DEV=$(echo $DEVS | grep -o -E "$REGEX $1" | grep -o -E "$REGEX")
  echo $DEV
}

signalble() {
  hcitool lecc $1 > /dev/null 2>&1 &
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

    status=$(curl -s "$API_URL/locks/$lock_id?access_token=$ACCESS_TOKEN" | jq '{state,avr_update_progress,ble_update_progress,updated_at,next_wake,pending_activity,serial_number,hardware_id}')
    lock_state=$(echo $status | jq -r '.state')
    next_wake_utc=$(echo $status | jq -r '.next_wake')
    next_wake=$(date -d "$next_wake_utc")
    last_update_utc=$(echo $status | jq -r '.updated_at')
    last_update=$(date -d "$last_update_utc")
    avr_progress=$(echo $status | jq -r '.avr_update_progress')
    ble_progress=$(echo $status | jq -r '.ble_update_progress')
    pending_id=$(echo $status | jq -r '.pending_activity.id')
    serial_num=$(echo $status | jq -r '.serial_number')
    hardware_id=$(echo $status | jq -r '.hardware_id')
    echo "State of lock \"$2\"
State:		$lock_state
Last Updated:	$last_update
Next Update:	$next_wake"
    if [[ "$avr_progress" -ne "100" ]]
    then
      echo "AVR Progress:	$avr_progress%"
    fi
    if [[ "$ble_progress" -ne "100" ]]
    then
      echo "BLE Progress:	$ble_progress%"
    fi
    echo "Pending:	$pending_id"
    echo "Serial#:      $serial_num"
    echo "Hardware ID:  $hardware_id"
  fi
  ;;
lock|unlock)
  if [[ -z "$2" ]]
  then
    echo "Specify a unit to $1"
    exit -1
  else
    if [[ "$3" == "immed" ]] ; then
      if (( EUID != 0 )) ; then
        echo "You must be root to $1 immediately." 1>&2
        exit 100
      fi
    fi
    lock_id=$(getlockid "$2")
    if [[ "$3" == "immed" ]] ; then
      lock_hwid=$(getlockhwid "$2")
      lock_bleaddr=$(findlockbleaddr $lock_hwid)
      signalble "$lock_bleaddr"
    fi

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
