#!/bin/sh

fd -HI '^\.git$' |
while read repo
do
	repo=$(dirname "${repo}")
	(
		cd "${repo}"
		[ -z "$(git status --porcelain=v1 2>/dev/null)" ] || echo "${repo}"
	)
done

