#!/usr/bin/env bash

source src/action.bash
source src/util.bash

action_window_list() {
	niri msg -j windows |
		jq -r -L "jq" \
			'
	import "fzf" as fzf;

	[
		.[]
		| select(.is_focused | not)
		| { "search": "\(.app_id)/\(.title)"
			, "data":   { "window": .id } | @json
			, "display": [] 
		}
	]
	| fzf::to_entries
	'
}

action_window_group() {
	action_add "goto" "enter"
	action_add "goto" "ctrl-l"
}

action_callback_goto_data() {
	niri msg action focus-window --id "${hwm_action["window"]}"
}
