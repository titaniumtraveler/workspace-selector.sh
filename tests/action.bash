#!/usr/bin/env bash

source "src/testing.bash"
source "src/action.bash"

reset_env() {
	declare -a hwm_action=()
}

test_action_add() {
	action_add "bind" "enter" --fallback-query
	testing_assert_eq "${hwm_action_bindings[0]}" "--bind=enter:become:echo bind:data:{2}"
	testing_assert_eq "${hwm_action_bindings[1]}" "--bind=enter:+become:echo bind:query:{q}"

	action_add "bind" "ctrl-n" --query
	testing_assert_eq "${hwm_action_bindings[2]}" "--bind=ctrl-n:become:echo bind:query:{q}"

	action_add "goto" "ctrl-g" --fallback-query
	testing_assert_eq "${hwm_action_bindings[3]}" "--bind=ctrl-g:become:echo goto:data:{2}"
	testing_assert_eq "${hwm_action_bindings[4]}" "--bind=ctrl-g:+become:echo goto:query:{q}"

	action_add "exit" "esc" --query
	testing_assert_eq "${hwm_action_bindings[5]}" "--bind=esc:become:echo exit:query:{q}"

	testing_assert_eq "${#hwm_action_bindings[@]}" "6"
}

test_action_parse() {
	local input
	local -A hwm_action

	assert_parse_result() {
		# shellcheck disable=SC2034
		input="$1" # `input` is used as nameref
		hwm_action=()
		action_parse input

		testing_assert_eq "$2" "${hwm_action["action"]}"
		testing_assert_eq "$3" "${hwm_action[type]}"
		testing_assert_eq "$4" "$(declare -p hwm_action)"
	}

	assert_parse_result 'bind:data:{"data":"data"}' \
		"bind" "data" \
		'declare -A hwm_action=([type]="data" [action]="bind" [data]="data" )'

	assert_parse_result 'bind:query:query' \
		"bind" "query" \
		'declare -A hwm_action=([query]="query" [type]="query" [action]="bind" )'
}

testing_run "$@"
