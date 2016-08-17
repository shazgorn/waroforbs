#!/bin/sh

git fetch
git clone
sh front.sh stop
pkill --pidfile tmp/pids/app.pid
####
sh front.sh start
sh rwl.sh gen
