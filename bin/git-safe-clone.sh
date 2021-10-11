#!/bin/sh
# Origin: https://gist.github.com/tribut/50c0f7d0b8341fa6d1784c317d5275f0
# 
# Clone a git repository, but make sure that it has a valid signature
# before actually checking it out.
#
# Note that this will always clone the master branch and probably doesn't
# exactly behave like "git clone" in other ways.
set -e

fail() {
  echo "$*" >&2
  exit 1
}

giturl="$1"
target="$2"
ref="master"
# see https://tribut.de/blog/git-commit-signatures-trusted-keys
gitgpgopts="-c gpg.program=selfgpg"

[ "$#" -ne 2 ] && fail "call me like this: $(basename "$0") git-url target-dir"
[ -e "$target" ] && fail "$target already exists"

git ls-remote --exit-code "$giturl" "$ref" >/dev/null ||
  fail "$giturl does not exists or has no $ref branch"
git init -- "$target"
cd -- "$target"
git remote add origin -- "$giturl"
git fetch -q --progress origin
# This should probably not be needed?! merge just ignores --verify-signatures...
git $gitgpgopts verify-commit "origin/$ref" ||
  fail "origin/$ref does not have a valid signature"
git $gitgpgopts merge --ff-only --verify-signatures "origin/$ref"
git branch -q --set-upstream-to="origin/$ref"

