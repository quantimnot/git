#!/bin/sh -u

git branch -D "${1}" &&
	git push --delete origin "${1}" &&
	git fetch --all --prune
