#!/bin/sh

# remove any bad refs
git remote prune origin

# remove branches that have already been merged
git branch --r --merged origin/master | grep -v 'HEAD |master' | grep origin | sed 's/origin//origin :/' | xargs -L 1 git push

