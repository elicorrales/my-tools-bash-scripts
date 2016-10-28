#!/usr/bin/bash

set -m

trap _trap_ctrl_c INT;

#######################################################################
#######################################################################
#######################################################################
#INITIALIZATION
#######################################################################
#######################################################################
#######################################################################

this_tool_is_already_running=$(ps -ef |grep "$(basename $0)");

if [ "$this_tool_is_already_running" != "" ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "This tool is already running in another window.....";
	echo "... shutting down this one."
	echo "============================================================";
	echo;echo;echo;
	exit 0;
fi

#######################################################################
function shutdown_mysqld {
#######################################################################
is_mysql_running=$(ps -ef |grep mysqld);
if [ "$is_mysql_running" != "" ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "Shutting down mysqld....";
	echo "============================================================";
	echo;echo;echo;

	mysqladmin.exe -h 127.0.0.1 -u root shutdown
fi;

fg >/dev/null 2>&1;

return 0;
#######################################################################
} # end function shutdown_mysqld
#######################################################################


#######################################################################
function _exit {
#######################################################################
echo;echo;echo;
echo "============================================================";
echo "Start _exit()....";
echo "============================================================";
echo;echo;echo;

shutdown_mysqld;

wait;

exit $1;

#######################################################################
} # end function _exit
#######################################################################

#######################################################################
_hit_ctrl_c=no;
function _trap_ctrl_c {
#######################################################################


echo;echo;echo;
echo "============================================================";
echo "Start _trap_ctrl_c()....";
echo "============================================================";
echo;echo;echo;
if [ "$_hit_ctrl_c" = "no" ];
then
	_hit_ctrl_c=yes;
	_exit;
fi

#######################################################################
} # end function _exit
#######################################################################

#######################################################################
function start_mysqld {
#######################################################################
is_mysqld_running=$(ps -ef |grep mysqld);

if [ "$is_mysqld_running" = "" ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "Starting mysqld ....";
	echo "============================================================";
	echo;echo;echo;

	mysqld --console &
else
	echo;echo;echo;
	echo "============================================================";
	echo "mysqld was ALREADY running....";
	echo "============================================================";
	echo;echo;echo;
	read -p "Press <ENTER>";
fi

return 0;
#######################################################################
} # end function _exit
#######################################################################



#######################################################################
#######################################################################
#######################################################################
# MAIN MENU - start of script
#######################################################################
#######################################################################
#######################################################################

start_mysqld 

wait;

_exit 0;