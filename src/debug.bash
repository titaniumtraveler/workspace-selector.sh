#!/usr/bin/env bash

((hwm_debug)) && {
	return
}
declare -Ai hwm_debug

debug_println() {
	printf '[DEBUG] %s\n' "$@" >&2
}

debug_print_to() {
	while read -r line; do
		debug_println "$line"
	done
}

debug_event_print() {
	local event_name="$1"
	local event_position="$2"

	printf '%s at %s\n' "$event_name" "$event_position" |
		debug_print_to
}

debug_call_location() {
	local depth="$1"
	printf '<%s:%s:%s>' "${BASH_SOURCE[$depth]}" "${FUNCNAME[$depth]}" "${BASH_LINENO[$depth - 1]}"
}

debug_event() {
	local event_name="$1"

	((hwm_debug["$event_name"])) &&
		{
			debug_event_print "$event_name" "$(debug_call_location 2)"
			return 0
		}

	((hwm_debug['debug:event'])) && {
		debug_event_print "$event_name" "$(debug_call_location 2)"
	}

	return 1
}

debug_add_flag() {
	local flag="$1"
	shift

	while ! ((hwm_debug[$flag])); do
		hwm_debug+=("$flag" 1)
		flag="${flag%:*}"
	done
}

debug_load_from_env() {
	if [[ -n $HWM_DEBUG ]]; then
		readarray -d ',' -t <<<"$HWM_DEBUG"

		# strip trailing newline added by `<<<`
		MAPFILE[-1]="${MAPFILE[-1]::-1}"

		for flag in "${MAPFILE[@]}"; do
			debug_add_flag "$flag"
		done

		debug_event "debug:load" && {
			debug_println "enabled debug flags:"
			printf '  "%s"\n' "${!hwm_debug[@]}" |
				debug_print_to
		}
	fi
}
