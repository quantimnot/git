#!/bin/sh
# Modified from: Gwen Lofman https://gist.github.com/glfmn/0c5e9e2b41b48007ed3497d11e3dbbfa

EXIT_CODE=0

# Git Metadata
BRANCH_NAME=$(git branch --format '%(refname:lstrip=2)')
STASH_NAME="pre-commit-$(date +%s) on ${BRANCH_NAME}"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

run_pre_commit_tests() {
	if [ -f sw.yml ]; then
		sw test -q pre-commit
	elif [ -f makefile ] || [ -f Makefile ]; then
		make test-pre-commit >/dev/null 2>&1
	elif [ -f "$(basename "${PWD}").nimble" ]; then
		nimble test_pre_commit >/dev/null 2>&1
	elif [ -f config.nims ]; then
		nim r test_pre_commit >/dev/null 2>&1
	else
		# shellcheck disable=SC2059
		printf "${YELLOW}NONE DEFINED "
		true
	fi
}

# Check if commit is on a rebase, if not proceed as usual
if [ ! "${BRANCH_NAME}" = '(no branch)' ]; then
	stash=0
	if git diff-index --cached --quiet HEAD --; then
		echo "${YELLOW}NO STAGED CHANGES FOUND${NC}"
		exit 0
	else
		# shellcheck disable=SC2059
		printf "* ${BOLD}Checking for unstaged changes: "
		if git status --short | grep -q '^[^A-Z]'; then
			echo "${YELLOW}SOME EXIST${NC}"
			# shellcheck disable=SC2059
			printf "* ${BOLD}Stashing unstaged changes as '%s': " "${STASH_NAME}"
			if git stash push -q --keep-index --include-untracked -m "${STASH_NAME}"; then
				echo "${GREEN}DONE${NC}"
				stash=1
			else
				echo "${RED}FAILED TO CREATE STASH${NC}"
				exit 1
			fi
		fi
	fi

	# shellcheck disable=SC2059
	printf "* ${BOLD}Pre-commit checks: "
	if run_pre_commit_tests; then
		echo "${GREEN}PASS${NC}"
	else
		echo "${RED}FAIL${NC}"
		echo "If you still want to commit, use ${BOLD}'--no-verify'${NC}"
		EXIT_CODE=1
	fi

	if [ ${stash} -eq 1 ]; then
		# shellcheck disable=SC2059
		printf "* ${BOLD}Restoring stash '%s': " "${STASH_NAME}"
		if git reset --hard -q &&
			git stash apply --index -q &&
			git stash drop -q; then
			echo "DONE${NC}"
		else
			echo "${RED}FAILED${NC}"
		fi
	fi
else
	echo "* ${YELLOW}Skipping tests on branchless commit${NC}"
fi

exit ${EXIT_CODE}
