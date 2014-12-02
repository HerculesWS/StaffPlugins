#!/bin/bash
# Copyright (c) 2014 Hercules Dev Team
# Base author: Haru <haru@dotalux.com>
#
# This file is part of the script_mapquit plugin for Hercules
#
# This plugin is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This plugin is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
#

function usage {
	echo "Usage: $1 <login|char|map>"
	echo "   or: $1 <kill|quit|restart|status> <login|char|map>"
	echo "   or: $1 <norestart|dorestart>"
	exit 1
}

function isrunning {
	if [ ! -f $1.pid ]; then
		return 1
	fi
	if ! kill -0 $(<$1.pid); then
		return 1
	fi
	if [ -d /proc ]; then
		if ! grep $2 /proc/$(<$1.pid)/cmdline >/dev/null 2>&1; then
			return 1
		fi
	fi
	return 0
}

function norestart {
	touch .donotrestart
	echo "The servers won't be restarted on kill/quit."
}

function dorestart {
	rm -f .donotrestart >/dev/null 2>&1
	echo "The servers will be restarted on kill/quit."
}

if [ -z "$1" ]; then
	usage $0
fi

case "$1" in
	norestart)
		norestart
		exit 0
		;;
	dorestart)
		dorestart
		exit 0
		;;
	kill|quit|restart|status)
		MODE="$1"
		shift
		;;
	*)
		MODE="run"
		;;
esac

case "$1" in
	login|char|map)
		SERVER=$1
		EXECUTABLE="${1}-server"
		;;
	*)
		usage $0
		;;
esac

if [ "$MODE" == "quit" ]; then
	norestart
	MODE="kill"
elif [ "$MODE" == "restart" ]; then
	dorestart
	MODE="kill"
fi

if [ -f $SERVER.pid ]; then
	if isrunning $SERVER $EXECUTABLE; then
		case "$MODE" in
			kill)
				echo "Killing PID $(<$SERVER.pid)"
				kill $(<$SERVER.pid)
				exit 0
				;;
			status)
				echo "$SERVER is running."
				exit 0
				;;
			*)
				echo "$SERVER is still running with PID $(cat $SERVER.pid)"
				exit 1
				;;
		esac
	else
		case "$MODE" in
			kill)
				echo "Process not found."
				;;
			status)
				echo "$SERVER is not running."
				exit 1
				;;
		esac
	fi
	echo "Removing PID file..."
	rm $SERVER.pid
fi

while [ "$MODE" == "run" ]; do
	echo "Starting $SERVER server..."
	ulimit -Sc unlimited
	set -m
	./${EXECUTABLE} &
	echo $! > $SERVER.pid
	fg
	STATUS=$?
	echo "Removing PID file..."
	rm $SERVER.pid
	sleep 2
	if [ "$SERVER" == 'map' ]; then
		echo "Map server terminated.  Killing other servers as well..."
		if [ "$STATUS" -eq 100 ]; then
			# Mapserver requested a restart, let's remove any .donotrestart files first
			if [ -f .donotrestart ]; then
				dorestart
			fi
		elif [ "$STATUS" -eq 101 ]; then
			# Mapserver requested termination, let's add a .donotrestart file if there isn't one.
			norestart
		fi
		for i in *.pid; do
			if [ "$i" != "*.pid" ]; then
				kill $(<$i)
			fi
		done
		sleep 5
	fi
	if [ -f .donotrestart ]; then
		echo "NOT restarting the $SERVER server."
		echo "Please remove .donotrestart if you want it to restart automatically"
		break
	fi
	echo "Restarting $SERVER"
done
