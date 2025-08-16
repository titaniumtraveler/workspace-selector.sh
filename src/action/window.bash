#!/usr/bin/env bash

source src/action.bash
source src/util.bash

action_window_list() {
	niri msg -j windows |
		jq -r -L "jq" --argjson "workspaces" "$(niri msg -j workspaces)" \
			'
	import "fzf" as fzf;

	def resolve_workspace:
		.workspace_id | . as $id
		| $workspaces[] 
		| select(.id == $id)
	;

	[
		.[]
		| select(.is_focused | not)
		| { "search": "\(resolve_workspace.name)/\(.app_id)/\(.title)"
			, "data":   { "window": .id } | @json
			, "display": [] 
		}
	]
	| fzf::to_entries
	'
}

action_window_group() {
	action_multi

	action_add "goto" "enter"
	action_add "goto" "ctrl-l"

	action_add_transform "ctrl-a" \
		'#bash

			name="$(workspace-selector.sh workspace-select)"
			echo exclude-multi

			printf "%s\n" {+2} |
				jq -c --arg "name" "$name" "{Action:{MoveWindowToWorkspace:{window_id:.window,reference:{Name:\$name}, focus: false}}}" |
				tee /proc/self/fd/2 |
				socat STDIO UNIX:"$NIRI_SOCKET" >&2
		'
}

action_callback_goto_data() {
	niri msg action focus-window --id "${hwm_action["window"]}"
}
