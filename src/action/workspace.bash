#!/usr/bin/env bash

source src/action.bash

action_workspace_list() {
	hypr-workspace-manager read |
		jq -r -L "jq" \
			'
	import "workspace" as workspace;
	import "fzf"       as fzf;

	workspace::list | workspace::display | fzf::to_entries
	'
}

action_workspace_group() {
	action_add "goto" "ctrl-g" --fallback-query
	action_add "moveto" "ctrl-m" --fallback-query
}

action_callback_goto_data() {
	hypr workspace "name:${hwm_action["workspace"]}"
}

action_callback_goto_query() {
	hypr-workspace-manager create "${hwm_action["query"]}" >/dev/null
	hypr workspace "name:${hwm_action["query"]}"
}

action_callback_moveto_data() {
	hypr movetoworkspace "name:${hwm_action["workspace"]},activewindow"
}

action_callback_moveto_query() {
	hypr-workspace-manager create "${hwm_action["query"]}" >/dev/null
	hypr movetoworkspace "name:${hwm_action["query"]},activewindow"
}

action_workspace_group_register() {
	hwm_action["register"]="$1"

	action_add "bind" "enter" --fallback-query
	action_add "bind" "ctrl-n" --query
}

action_callback_bind_data() {
	hypr-workspace-manager bind "${hwm_action["workspace"]}" "${hwm_action["register"]}"
}

action_callback_bind_query() {
	hypr-workspace-manager bind "${hwm_action["query"]}" "${hwm_action["register"]}"
}
