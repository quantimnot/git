#!/bin/sh

git for-each-ref --format=\
'%(if:notequals=origin)%(upstream:remotename)%(then)%(refname:short)%(end)' \
refs/heads | rg -N '\S'
