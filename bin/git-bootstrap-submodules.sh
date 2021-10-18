#!/bin/sh

git submodule deinit -f .

git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
	while read -r path_key path; do
		url_key=$(echo "${path_key}" | sed 's/\.path/.url/')
		url=$(git config -f .gitmodules --get "${url_key}")
		git submodule add "${url}" "${path}"
	done
