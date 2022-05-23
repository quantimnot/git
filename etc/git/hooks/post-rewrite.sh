#!/bin/sh

case "$1" in
	rebase)
		[ -f .git/hooks/post-merge ] &&
		exec .git/hooks/post-merge ;;
esac
