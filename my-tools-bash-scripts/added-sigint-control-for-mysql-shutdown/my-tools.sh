#!/usr/bin/bash

set -m

trap _trap_ctrl_c INT;


#######################################################################
function shutdown_mysqld {
#######################################################################
echo;echo;echo;
echo "============================================================";
echo "Shutting down mysqld....";
echo "============================================================";
echo;echo;echo;
mysqladmin.exe -h 127.0.0.1 -u root shutdown
fg 2>/dev/null;

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
echo;echo;echo;
echo "============================================================";
echo "MAIN: Starting mysqld script....";
echo "============================================================";
echo;echo;echo;

mysqld --console &

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
} # end function create_database
#######################################################################

#######################################################################
function drop_table {
#######################################################################
selected_database=$1;
selected_table=$2;
while [ 1 ];
do

table_dropped=$(mysql -h 127.0.0.1 -u root << MYSQL
use $selected_database;
drop table $selected_table;
MYSQL
)
	echo $table_dropped;

	break;

done;   


return 0;
#######################################################################
} # end function drop_database
#######################################################################

#######################################################################
function act_on_selected_table {
#######################################################################
selected_database=$1;
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
} # end function act_on_selected_database
#######################################################################

#######################################################################
function show_tables {
#######################################################################
selected_database=$1;
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
} # end function act_on_selected_database
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
while [ 1 ];
do

# a HERE DOCUMENT, output into a local Bash variable 'databases'.
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
		b)
			break;
			;;
		e)
			_exit 0;
			;;
		cnd)
			create_database
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
	echo; echo;
	echo "|=============================================|"
	echo "|             MySQL Menu                      |"
	echo "|=============================================|"
	echo "|st) Start MySQL                              |"
	echo "|sh) Shutdown  MySQL                          |"
	echo "|                                             |"
	echo "|sd) Show Databases                           |"
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
