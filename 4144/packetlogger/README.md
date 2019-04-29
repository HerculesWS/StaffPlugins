Hercules plugin: packetlogger
=============================

Log all packets for login, char, map servers (including inter server packets) into log directory.

Logged data in readable format with hex and dec values

File name format: SERVER_PACKETVERSION_TYPE_FD.log

Where:

SERVER is one of login, char, map.

PACKETVERSION is selected packet version in server

TYPE is one of main, re, zero

FD is connection number.

Example: login_20190116_main_7.log
