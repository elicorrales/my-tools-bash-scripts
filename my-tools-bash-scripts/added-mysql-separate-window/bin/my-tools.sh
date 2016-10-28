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

BIN=${HOME}/bin;
if [ ! -d $BIN ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "ERROR: There is no $BIN directory.";
	echo "       Do not have access to child scripts." 
	echo "============================================================";
	echo;echo;echo;
	read -p "Press <ENTER>:";
	exit 1; # no access yet to _exit
fi

MYTOOLS=$BIN/my-tools;
if [ ! -d $MYTOOLS ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "ERROR: There is no $MYTOOLS directory.";
	echo "       Do not have access to child scripts." 
	echo "============================================================";
	echo;echo;echo;
	read -p "Press <ENTER>:";
	exit 1; # no access yet to _exit
fi

SETTINGS=${HOME}/.my-tools-settings;
if [ ! -d $SETTINGS ];
then
	echo;echo;echo;
	echo "============================================================";
	echo "NOTE: There is no $SETTINGS directory. Creating." 
	echo "============================================================";
	mkdir $SETTINGS;
	echo;echo;echo;
fi;

cd $MYTOOLS;

#######################################################################
function _exit {
#######################################################################
echo;
echo "============================================================";
echo "Start _exit()....";
echo "============================================================";
echo;

shutdown_mysqld;

wait;

exit $1;

#######################################################################
} # end function _exit
#######################################################################

#######################################################################
function is_mysqld_running {
#######################################################################
echo;
echo "============================================================";
echo "is_mysqld_running....";
echo "============================================================";
echo;
_mysql_is_running=$(ps -ef|grep mysqld);

if [ "$_mysql_is_running" != "" ];
then
	echo "============================================================";
	echo "YES mysqld is RUNNING....";
	echo "============================================================";
	echo;
	return 1;
else
	echo "============================================================";
	echo "NO mysqld is NOT RUNNING....";
	echo "============================================================";
	echo;
	return 0;
fi;

#######################################################################
} # end function is_mysqld_running
#######################################################################

#######################################################################
function shutdown_mysqld {
#######################################################################
is_mysqld_running;
rtn=$?

if [ $rtn -eq 1 ];
then

	echo;echo;
	echo "============================================================";
	echo "Shutting down mysqld....";
	echo "============================================================";
	echo;
	mysqladmin.exe -h 127.0.0.1 -u root shutdown
	fg 2>/dev/null;
fi;

#######################################################################
} # end function shutdown_mysqld
#######################################################################


#######################################################################
function _trap_ctrl_c {
#######################################################################


echo;echo;
echo "============================================================";
echo "Start _trap_ctrl_c()....";
echo "============================================================";
echo;echo;
_exit;

#######################################################################
} # end function _exit
#######################################################################

#######################################################################
function start_mysqld {
#######################################################################
mode=$1;
is_mysqld_running;
rtn=$?

if [ $rtn -eq 0 ];
then
	echo "============================================================";
	echo "Starting mysqld ....";
	echo "============================================================";
	echo;echo;

	if [ "$mode" = "window" ];
	then
		echo "============================================================";
		echo "....starting mysqld in another window....";
		echo "============================================================";

		###########################################
		# size/pos is either default, or from
		# previous time.
		###########################################
		if [ -f $SETTINGS/MYSQL-SIZE-POS.txt ];
		then
			sizepos_settings="$(cat $SETTINGS/MYSQL-SIZE-POS.txt | sed 's/mintty//') ";
		else
			sizepos_settings="-s 130,30 -p,400 ";
		fi;

		###########################################
		mintty \
			-T MYSQL \
			-o ForegroundColour=255,255,0 \
			-o BackgroundColour=0,0,80 \
			$sizepos_settings \
			-R s \
			-e $MYTOOLS/my-tools-run-mysql-in-window.sh > $SETTINGS/MYSQL-SIZE-POS.txt 2>/dev/null &

	elif [ "$mode" = "no_output" ];
	then
		echo "============================================================";
		echo "....starting mysqld with NO output....";
		echo "============================================================";

		mysqld --console 2>/dev/null &
	else
		echo "============================================================";
		echo "....starting mysqld in THIS same window....";
		echo "============================================================";

		mysqld --console &
	fi
else
	echo "============================================================";
	echo "mysqld was ALREADY running....";
	echo "============================================================";
	echo;echo;
fi

return 0;
#######################################################################
} # end function _exit
#######################################################################


#######################################################################
function view_rows {
#######################################################################
selected_database=$1;
selected_table=$2;

if [ "$selected_database" = "" ] || [ "$selected_table" = "" ];
then
	echo
	echo "ERROR: no database or table param passed to view_rows func";
	echo
	return 1;
fi

mysql -t -h 127.0.0.1 -u root << MYSQL 
use $selected_database;
select * from $selected_table;
MYSQL


return 0;
#######################################################################
} # end function view_rows
#######################################################################


#######################################################################
function drop_table {
#######################################################################
selected_database=$1;
if [ "$selected_database" = "" ];
then
	echo
	echo "ERROR: no database param passed to func";
	echo
	return 1;
fi

selected_table=$2;
while [ 1 ];
do

	echo; echo;
	echo "|=============================================|"
	echo "|Are You SURE you want to drop table:         |"
	echo "|      $selected_database:$selected_table ?"
	echo "|=============================================|"
	echo "|y) Drop Table                                |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		y)
table_dropped=$(mysql -h 127.0.0.1 -u root << MYSQL
use $selected_database;
drop table $selected_table;
MYSQL
)
			echo $table_dropped;

			break;
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done;   


return 0;
#######################################################################
} # end function drop_table
#######################################################################

#######################################################################
function act_on_selected_table {
#######################################################################
selected_database=$1;
if [ "$selected_database" = "" ];
then
	echo
	echo "ERROR: no database param passed to func";
	echo
	return 1;
fi

selected_table_idx=$2;
selected_table="";
while [ 1 ];
do

tables=$(mysql -h 127.0.0.1 -u root << MYSQL
use $selected_database;
show tables;
MYSQL
)
	tables=$(echo $tables|sed "s/Tables_in_$selected_database//");
   
	i=1;
	for table in $tables;
	do
		if [ $i -eq $selected_table_idx ];
		then
			selected_table=$table;
		fi
		i=$((i+1));
	done

	echo; echo;
	echo "|=============================================|"
	echo "|MySQL Databases Menu:$selected_table"
	echo "|=============================================|"
	echo "|vr) View Rows                                |"
	echo "|dt) Drop Table                               |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		vr)
			view_rows $selected_database $selected_table
			;;
		dt)
			drop_table $selected_database $selected_table
			break;
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;
#######################################################################
} # end function act_on_selected_table
#######################################################################

#######################################################################
function show_tables {
#######################################################################
selected_database=$1;
if [ "$selected_database" = "" ];
then
	echo
	echo "ERROR: no database param passed to func";
	echo
	return 1;
fi

while [ 1 ];
do

tables=$(mysql -h 127.0.0.1 -u root << MYSQL
use $selected_database;
show tables;
MYSQL
)

tables=$(echo $tables | sed "s/Tables_in_$selected_database//");


	echo; echo;
	echo "|=============================================|"
	echo "|MySQL Databases Menu:$selected_database"
	echo "|=============================================|"

	i=1;
	for table in $tables;
	do
	echo "| $i) $table"
	i=$((i+1));
	done

	echo "|                                             |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		[0-9]*)
			act_on_selected_table $selected_database $menu_choice
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;
#######################################################################
} # end function show_tables
#######################################################################


#######################################################################
function create_database {
#######################################################################
new_database="";
while [ 1 ];
do
	while [ "$new_database" = "" ];
	do
		read -p "New Database Name?: " new_database;
	done;

# a HERE DOCUMENT, output into a local Bash variable 'databases'.
database_created=$(mysql -h 127.0.0.1 -u root << MYSQL
create database $new_database;
MYSQL
)
	echo $database_created;

	break;

done;   


return 0;
#######################################################################
} # end function create_database
#######################################################################

#######################################################################
function drop_database {
#######################################################################
selected_database=$1;
if [ "$selected_database" = "" ];
then
	echo
	echo "ERROR: no database param passed to func";
	echo
	return 1;
fi

while [ 1 ];
do

database_dropped=$(mysql -h 127.0.0.1 -u root << MYSQL
drop database $selected_database;
MYSQL
)
	echo $database_dropped;

	break;

done;   


return 0;
#######################################################################
} # end function drop_database
#######################################################################

#######################################################################
function act_on_selected_database {
#######################################################################
selected_database_idx=$1;
selected_database="";
while [ 1 ];
do

# a HERE DOCUMENT, output into a local Bash variable 'databases'.
databases=$(mysql -h 127.0.0.1 -u root << MYSQL
show databases;
MYSQL
)
	databases=$(echo $databases|sed 's/Database//');
   
	### for-loop to display our database list, numbered.
	i=1;
	for db in $databases;
	do
		if [ $i -eq $selected_database_idx ];
		then
			selected_database=$db;
		fi
		i=$((i+1));
	done


	echo; echo;
	echo "|=============================================|"
	echo "|MySQL Databases Menu:$selected_database"
	echo "|=============================================|"
	echo "|st) Show Tables                              |"
	echo "|dd) Drop Database                            |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		st)
			show_tables $selected_database
			;;
		dd)
			drop_database $selected_database
			break;
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;
#######################################################################
} # end function act_on_selected_database
#######################################################################

#######################################################################
function mysql_show_databases_menu {
#######################################################################
if [ $rtn -eq 0 ]; then return 0; fi;

while [ 1 ];
do

# a HERE DOCUMENT, output into a local Bash variable 'databases'.
databases=$(mysql -h 127.0.0.1 -u root << MYSQL
show databases;
MYSQL
)
   
	databases=$(echo $databases|sed 's/Database//');

	echo; echo;
	echo "|=============================================|"
	echo "|             MySQL Databases Menu            |"
	echo "|=============================================|"

	### for-loop to display our database list, numbered.
	i=1;
	for db in $databases;
	do
	echo "| $i) $db"
	i=$((i+1));
	done

	echo "|                                             |"
	echo "| cnd) Create New Database                    |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		[0-9]*)
			act_on_selected_database $menu_choice
			;;
		cnd)
			create_database
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;
#######################################################################
} # end function mysql_show_databases_menu
#######################################################################

#######################################################################
function mysql_menu {
#######################################################################
while [ 1 ];
do
	is_mysqld_running;
	rtn=$?

	echo; echo;
	echo "|=============================================|"
	echo "|             MySQL Menu                      |"
	echo "|=============================================|"

	if [ $rtn -eq 0 ];
	then

	echo "|st) Start MySQL       (outputs this window)  |"
	echo "|stn) Start MySQL      ( NO output )          |"
	echo "|stw) Start MySQL      ( another window )     |"
	echo "|                                             |"

	else

	echo "|sh) Shutdown  MySQL                          |"
	echo "|                                             |"
	echo "|sd) Show Databases                           |"

	fi;

	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"

	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		st)
			start_mysqld
			;;
		stn)
			start_mysqld no_output
			;;
		stw)
			start_mysqld window
			;;
		sh)
			shutdown_mysqld
			;;
		sd)
			mysql_show_databases_menu
			;;
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;
#######################################################################
} # end function mysql_menu
#######################################################################

#######################################################################
function main_menu {
#######################################################################
while [ 1 ];
do
	echo; echo;
	echo "|=============================================|"
	echo "|              Main Menu                      |"
	echo "|=============================================|"
	echo "|my) MySQL Utiliies                           |"
	echo "|=============================================|"
	echo "|e) Exit                                      |"
	echo "|=============================================|"

	menu_choice="";
	echo;
	read -p "Please make a selection:" menu_choice

	case $menu_choice in

		my)
			mysql_menu
			;;
		e)
			break;
			;;
		*)
			echo;echo;
			echo "Invalid selection: $menu_choice"
			echo;echo;
			;;
	esac
done

return 0;

#######################################################################
} # end function main_menu
#######################################################################




#######################################################################
#######################################################################
#######################################################################
# MAIN MENU - start of script
#######################################################################
#######################################################################
#######################################################################

main_menu;

_exit 0;
