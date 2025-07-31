#!/usr/bin/env bash

SCRIPTDIR="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"
cd "$SCRIPTDIR" || exit 1

source src/lib.bash

main() {
	local action_list="$1"

	case "$action_list" in
	workspace)
		source src/debug.bash
		debug_load_from_env

		source src/action/util.bash
		source src/action/workspace.bash

		action_group_util
		action_workspace_group
		[[ -v 2 ]] && action_workspace_group_register "$2"
		;;
	window)
		source src/debug.bash
		debug_load_from_env

		source src/action/util.bash
		source src/action/window.bash

		action_group_util
		action_window_group
		;;
	*)
		echo "cmd \"$action_list\" not available" >&2
		return 1
		;;
	esac

	# shellcheck disable=SC2034 # `input` is used as nameref
	input="$(action_fzf_run "$action_list")"

	action_parse input
	action_run
}

main "$@"
