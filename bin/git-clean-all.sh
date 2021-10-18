#!/bin/sh

HEAD_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for branch in $(git branch --list --format '%(refname:lstrip=2)'); do
	echo "cleaning ${branch}"

	echo "remove any bad refs"
	git remote prune "${branch}"

	echo "remove branches that have already been merged"
	git branch --r --merged "${branch}/${HEAD_BRANCH}" | grep -v "HEAD |${HEAD_BRANCH}" | grep "${branch}" | sed "s/${branch}/${branch} :/" | xargs -L 1 git push
done
