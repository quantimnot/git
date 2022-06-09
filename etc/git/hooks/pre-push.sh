#!/bin/sh

# Called by "git push" after it has checked the remote status, but before
# anything has been pushed.  If this script exits with a non-zero status nothing
# will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local oid> <remote ref> <remote oid>
#
# There are currently 2 checks:
# - regex defined by config 'check.notinmessage' matches commit message
# - regex defined by config 'check.notindiff' matches commit diff additions

# shellcheck disable=SC2034
remote="$1"
url="$2"

zero="0000000000000000000000000000000000000000"

# shellcheck disable=SC2034
while read -r local_ref local_oid remote_ref remote_oid; do
	if test "$local_oid" = "$zero"; then
		# Handle delete
		:
	else
		if test "$remote_oid" = "$zero"; then
			# New branch, examine all commits from fork point
			fork_point="$(git merge-base --fork-point "$local_ref")"
			range="$fork_point^..$local_oid"
		else
			# Update to existing branch, examine new commits
			range="$remote_oid..$local_oid"
		fi

		# Check for excluded commit message patterns
		excl=$(git config --get check.notinmessage)
		if [ -n "$excl" ]; then
			commit=$(git rev-list -1 -i --grep "$excl" "$range")
			if test -n "$commit"; then
				echo >&2 "Found '$excl' in commit message of $local_ref, not pushing"
				exit 1
			fi
		fi

		# Check for excluded patterns in diff
		excl=$(git config --get check.notindiff)
		if [ -n "$excl" ]; then
			if git diff -U0 "$range" | sed -n '/^+++ b/d;/^+/p' | grep -E "$excl"; then
				echo >&2 "Found '$excl' in diff of $local_ref, not pushing"
				exit 1
			fi
		fi
	fi
done

if command -v git-lfs >/dev/null 2>&1; then
	git lfs pre-push "$@"
else
	cat >&2 <<-EOF
		This repository is configured for Git LFS but 'git-lfs' was not found on your path.
		If you no longer wish to use Git LFS, remove this hook by deleting .git/hooks/pre-push.
	EOF
	exit 2
fi
