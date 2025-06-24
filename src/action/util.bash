#!/usr/bin/env bash

source src/util.bash
source src/action.bash

action_group_util() {
	hwm_action_bindings+=("--bind=enter:")
	action_add "exit" "esc" --query
}

action_callback_exit_query() {
	exec
}
