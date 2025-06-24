#!/usr/bin/env bash

((hwm_util)) && return
declare hwm_util=""

hypr() {
	local dispatcher="$1"
	local args="${2:-""}"

	local hypr_msg=""
	if ! hypr_msg="$(hyprctl dispatch "$dispatcher" "$args")"; then
		printf '[HYPR] %s\n' "$hypr_msg"
	fi
}
