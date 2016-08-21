#!/bin/sh

sh front.sh stop
sh rwl.sh stop

git fetch
git pull

sh front.sh start
sh rwl.sh gen
