#!/usr/bin/env bash

((hwm_util)) && return
declare hwm_util=""

niri_mgr() {
	local ws_mgr_msg=""
	if ! ws_mgr_msg="$(niri-workspace-manager "$@" 2>&1)"; then
		printf '[niri-workspace-manager] %s\n' "$ws_mgr_msg"
	fi
}
