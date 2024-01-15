#!/bin/sh
top -b -n 1 -o TIME+ | tail -n +8 | head -n 10 | grep -E 'ksoftirqd|java|mono' | awk '$2 >= 86400 {print "Forcefully killing process with pid " $1; system("kill -9 " $1)}'
