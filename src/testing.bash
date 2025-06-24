#!/usr/bin/env bash

SCRIPTDIR="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"
cd "$SCRIPTDIR" || exit 1

declare -i testing_test_failed=0

source "src/debug.bash"

testing_list() {
	local -n ref_list="$1"
	local -A test_name_keys=()
	shift

	for prefix in "$@"; do
		for test_name in $(compgen -A function "test_$prefix"); do
			test_name_keys+=("$test_name")
		done
	done

	ref_list+=("${!test_name_keys[@]}")
}

testing_test_runner() {
	name="$1"
	${name}
	return "$testing_test_failed"
}

testing_run() {
	local list=()
	testing_list list "${@-}"

	debug_load_from_env

	for test_name in "${list[@]}"; do
		local test_output=""

		if test_output="$(testing_test_runner "$test_name")"; then
			printf 'test %s ... ok\n' "$test_name"
		else
			printf 'test %s ... FAILED in %d places\n' "$test_name" "$?"
			printf '%s\n' "$test_output"
		fi
	done
}

testing_assert_eq() {
	local left="$1"
	local right="$2"
	[[ "$left" == "$right" ]] || {
		testing_test_failed+=1

		printf 'assertion `left == right` failed\n'
		printf '  left `%s`\n' "$left"
		printf ' right `%s`\n' "$right"
		printf '\n'
	}
}
