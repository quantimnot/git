#!/bin/sh -u

git reset --soft "${1}" &&
	git commit --edit -m"$(git log --format=%B --reverse 'HEAD..HEAD@{1}')"
