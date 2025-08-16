#!/usr/bin/env bash

((hwm_action)) && return
declare -A hwm_action=()
declare -a hwm_action_bindings=()

source src/debug.bash

action_parse() {
	local -n ref_input="$1"

	debug_event "action:parse:input" &&
		debug_println "$ref_input"

	hwm_action["action"]="${ref_input%%:*}"
	ref_input="${ref_input:${#hwm_action["action"]}+1}"

	hwm_action["type"]="${ref_input%%:*}"
	ref_input="${ref_input:${#hwm_action["type"]}+1}"

	local arr=()
	readarray -t arr <<<"$(
		echo "$ref_input" |
			case "${hwm_action["type"]}" in
			data)
				jq -r 'to_entries[] | .key, .value'
				;;
			query)
				jq -r --raw-input --slurp '"query", .'
				;;
			esac
	)"

	for ((i = 0; i + 1 < ${#arr[@]}; i += 2)); do
		hwm_action+=("${arr[$i]}" "${arr[$i + 1]}")
	done

	debug_event "action:parse" && {
		cat <<-DEBUG | debug_print_to
			action: \`${hwm_action["action"]}\`
			type:   \`${hwm_action["type"]}\`
			data:   \`$(declare -p hwm_action)\`
		DEBUG
	}
	debug_event "action:parse:exit" && exit
}

action_run_in_alacritty() {
	exec {pipe}<> <(:)

	exec {script}<<-BASH
		exec 0< "/proc/$BASHPID/fd/0"
		exec 1> "/proc/$BASHPID/fd/1"
		exec 2> "/proc/$BASHPID/fd/2"

		${@@Q}

		echo "finished" > "/proc/$BASHPID/fd/$pipe"
	BASH

	alacritty-ui.sh \
		bash "/proc/$BASHPID/fd/${script}"

	read -r -u "$pipe"

	exec {pipe}>&-
	exec {script}>&-
}

action_fzf_run() {
	local list="$1"

	debug_event "action:fzf" && {
		printf '%s\n' "${hwm_action_bindings[@]}" |
			debug_print_to
	}

	"action_${list}_list" |
		action_run_in_alacritty \
			fzf \
			--delimiter=$'\t' \
			--with-nth="1,3.." \
			--nth="1" \
			--layout=reverse \
			--tiebreak=index \
			--tabstop 32 \
			"${hwm_action_bindings[@]}"
}

action_run() {
	"action_callback_${hwm_action["action"]}_${hwm_action["type"]}"
}

action_add() {
	local name="$1"
	local key="$2"

	add_bind() {
		local type="$1"
		local expr="$2"
		local fallback="${3+"+"}"

		hwm_action_bindings+=("--bind=$key:${fallback}become:echo $name:$type:{$expr}")
	}

	case "$3" in
	"")
		add_bind "data" "2"
		;;
	--query)
		add_bind "query" "q"
		;;
	--fallback-query)
		add_bind "data" "2"
		add_bind "query" "q" --fallback
		;;
	esac
}

action_add_transform() {
	local key="$1"
	local cmd="$2"

	hwm_action_bindings+=("--bind=$key:transform:
		exec 2> \"/proc/$BASHPID/fd/2\"
		${cmd}
	"
	)
}

action_multi() {
	hwm_action_bindings+=("--multi")
}
