#!/usr/bin/env bash

source src/action.bash
source src/util.bash

action_workspace_list() {
	niri-workspace-manager read |
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
	niri_mgr goto-name "${hwm_action["workspace"]}"
}

action_callback_goto_query() {
	niri_mgr create "${hwm_action["query"]}" >/dev/null
	niri_mgr goto-name "${hwm_action["query"]}"
}

action_callback_moveto_data() {
	niri_mgr moveto-name "${hwm_action["workspace"]}"
}

action_callback_moveto_query() {
	niri_mgr create "${hwm_action["query"]}" >/dev/null
	niri_mgr moveto-name "${hwm_action["query"]}"
}

action_workspace_group_register() {
	hwm_action["register"]="$1"

	action_add "bind" "enter" --fallback-query
	action_add "bind" "ctrl-n" --query
}

action_callback_bind_data() {
	niri_mgr bind "${hwm_action["workspace"]}" "${hwm_action["register"]}"
}

action_callback_bind_query() {
	niri_mgr bind "${hwm_action["query"]}" "${hwm_action["register"]}"
}

action_workspace_select_group() {
	action_add "print" "enter" --fallback-query
}

action_callback_print_data() {
	echo "${hwm_action["workspace"]}"
}

action_callback_print_query() {
	echo "${hwm_action["query"]}"
}
