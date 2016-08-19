#!/bin/sh

git fetch
git clone
sh front.sh stop
sh rwl.sh stop
####
sh front.sh start
sh rwl.sh gen
