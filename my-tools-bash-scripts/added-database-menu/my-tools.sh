#!/usr/bin/bash


#######################################################################
function mysql_show_databases_menu {
#######################################################################
while [ 1 ];
do

# a HERE DOCUMENT, output into a local Bash variable 'databases'.
databases=$(mysql -h 127.0.0.1 -u root << 'MYSQL'
show databases;
MYSQL
)
   
	databases=$(echo $databases|sed 's/Database//');

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

	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"


	menu_choice="";
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		b)
			break;
			;;
		e)
			exit 0;
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
	echo "|=============================================|"
	echo "|             MySQL Menu                      |"
	echo "|=============================================|"
	echo "|1) Start MySQL                               |"
	echo "|2) Stop  MySQL                               |"
	echo "|                                             |"
	echo "|3) Show Databases                            |"
	echo "|=============================================|"
	echo "|b) Back                                      |"
	echo "|e) Exit This Tool                            |"
	echo "|=============================================|"

	menu_choice="";
	read -p "Please make a selection:" menu_choice

	case $menu_choice in
		1)
			$(mysqld --console) &
			;;
		2)
			mysqladmin.exe -h 127.0.0.1 -u root shutdown
			;;
		3)
			mysql_show_databases_menu
			;;
		b)
			break;
			;;
		e)
			exit 0;
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
	echo "|=============================================|"
	echo "|              Main Menu                      |"
	echo "|=============================================|"
	echo "|1) MySQL Utiliies                            |"
	echo "|=============================================|"
	echo "|e) Exit                                      |"
	echo "|=============================================|"

	menu_choice="";
	read -p "Please make a selection:" menu_choice

	case $menu_choice in

		1)
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

exit 0;
