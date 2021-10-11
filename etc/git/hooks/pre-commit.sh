#!/bin/sh
# Origin: Gwen Lofman https://gist.github.com/glfmn/0c5e9e2b41b48007ed3497d11e3dbbfa
# Changes:
#   - Replace grep with ripgrep.
#   - Replace sed with sd.
#   - Replace cargo with pkg.

STASH_NAME="pre-commit-$(date +%s)"
ROOT_DIR="$(git rev-parse --show-toplevel)"
BUILD_DIR="${ROOT_DIR}/target"
BRANCH_NAME=$(git branch --format '%(refname:lstrip=2)')
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Check if commit is on a rebase, if not proceed as usual
if [ ! $BRANCH_NAME = '(no branch)' ]
then
    stash=0
    # Check to make sure commit isn't emtpy, exit with status 0 to let git handle it
    # prevents blocking when ammending an empty commit
    if git diff-index --cached --quiet HEAD --; then
        echo "${RED}You've tried to commit an empty commit${NC}"
        echo "\tMake sure to add your changes with 'git add'"
        exit 0
    else
        # Stash all changes in the working directory so we test only commit files
        if git stash save -u -k -q $STASH_NAME; then
            echo "${YELLOW}Stashed changes as:${NC} ${STASH_NAME}\n\n"
            stash=1
        fi
    fi

    echo "${GREEN} Testing commit${NC}\n\n"

    # use && to combine test commands so if any one fails it's accurately represented
    # in the exit code
    echo pkg check &&
    echo pkg test

    # Capture exit code from tests
    status=$?

    # Revert stash if changes were stashed to restore working directory files
    if [ "$stash" -eq 1 ]
    then
        if git stash pop -q; then
            echo "\n\n${GREEN}Reverted stash command${NC}"
        else
            echo "\n\n${RED}Unable to revert stash command${NC}"
        fi
    fi

    # Inform user of build failure
    if [ "$status" -ne "0" ]
    then
        echo "${RED}Build failed:${NC} if you still want to commit use ${BOLD}'--no-verify'${NC}"
    fi

    # Exit with exit code from tests, so if they fail, prevent commit
    exit $status
else
    # Tests were skipped for rebase, inform user and exit zero
    echo "${YELLOW}Skipping tests on branchless commit${NC}"
    exit 0
fi

