#!/bin/bash

# init314
# version 1.0

if (( $EUID != 0 )); then
	echo "Run this script as root!"
	exit 1
fi

source ./prints.sh

adduserconf="/etc/adduser.conf"
configtxt="/boot/config.txt"
group="/etc/group"

audioout=1 #analog
deletepi=0

USER_R=""
USER_N=""
PASS_R=""
PASS_N=""
HOSTNAME=""

main()
{
	print_title "\nInit 314\n"
	
	check_arguments "$@"

	create_users
	set_root_user
	copy_to_home_dirs

	edit_configtxt
	setup_audio
	append_environment

	set_hostname
	append_hosts
	
	print_new_info
	
	delete_pi_user
	
	print_info "Exiting, press any key..."
	read -n 1
	return 0
}

#---------- CHECK ARGUMENTS ----------#
check_arguments()
{
    while (( "$#" )); do 
        arg=$(echo $1 | cut -d'=' -f1)
        parameter=$(echo $1 | cut -d'=' -f2)
        
        case "$arg" in
        
            "-userr")
                username=$(echo "$parameter" | cut -d';' -f1)
                password=$(echo "$parameter" | grep ";" | cut -d';' -f2)
                USER_R="$username"
                PASS_R="$password"
                ;;
                
            "-usern")
                username=$(echo "$parameter" | cut -d';' -f1)
                password=$(echo "$parameter" | grep ";" | cut -d';' -f2)
                USER_N="$username"
                PASS_N="$password"
                ;;
                
            "-hostname")
                HOSTNAME="$parameter"
                ;;
                
            "-deletepi")
                deletepi=1
                ;;
                
            *)
                echo "Unknown argument: $arg"
                ;;
                
            esac
            
        shift 
    done
}

#---------- USERS ----------#
create_users()
{
	print_info "Generating user names and passwords..."
	
	if [[ -z "$USER_R" ]] || [[ "$USER_R" == "" ]]; then USER_R="rootuser"; fi
	if [[ -z "$USER_N" ]] || [[ "$USER_N" == "" ]]; then USER_N="normaluser"; fi
	if [[ -z "$PASS_R" ]] || [[ "$PASS_R" == "" ]]; then PASS_R=$(base64 /dev/urandom | head -c 8 | tr -d '=+/'); fi
	if [[ -z "$PASS_R" ]] || [[ "$PASS_R" == "" ]]; then PASS_N=$(base64 /dev/urandom | head -c 8 | tr -d '=+/'); fi

	print_info "Setting DIR_MODE..."
	init314_replace "DIR_MODE=0755" "DIR_MODE=0750" $adduserconf

	print_info "Creating users..."
	adduser --disabled-password --gecos "" $USER_R
	adduser --disabled-password --gecos "" $USER_N

	print_info "Setting passwords..."
	echo "$USER_R:$PASS_R" | sudo chpasswd
	echo "$USER_N:$PASS_N" | sudo chpasswd
}

set_root_user()
{
	print_error "Adding root user to aditional groups..."
	usermod -a -G sudo,netdev,audio,video,bluetooth $USER_R
}

copy_to_home_dirs()
{
	print_info "Copying files for specific users from ./home_folders/*..."
	cp -r ./home_folders/user_r/. /home/$USER_R/
	cp -r ./home_folders/user_n/. /home/$USER_N/
	chown -R $USER_R:$USER_R /home/$USER_R
	chown -R $USER_N:$USER_N /home/$USER_N
}

#---------- CONFIG.TXT ----------#
edit_configtxt()
{
	print_info "Editing config.txt..."
	init314_replace "#hdmi_force_hotplug=1" "hdmi_force_hotplug=1" $configtxt
	init314_replace "#disable_overscan=1" "disable_overscan=1" $configtxt
}

#---------- AUDIO ----------#
setup_audio()
{
	print_info "Setting audio output to ANALOG..."
	amixer cset numid=3 "$audioout"
}

#---------- ENVIRONMENT ----------#
append_environment()
{
	print_info "Appending additional environment variables..."
	cat ./env_vars/environment.txt >> /etc/environment
}

#---------- HOSTNAME ----------#
set_hostname()
{
	print_info "Setting new hostname..." 
	if [[ -z "$HOSTNAME" ]] || [[ "$HOSTNAME" == "" ]]; then HOSTNAME="raspberrypi"; fi
	init314_replace "$(hostname)" "$HOSTNAME" /etc/hosts
	echo $HOSTNAME > /etc/hostname
}

#---------- HOSTS ----------#
append_hosts()
{
	print_info "Copying hosts files..."
	cp /etc/hosts /etc/hosts.backup
	cp ./hosts/hosts /etc/hosts
	print_info "Appending hosts files..."
	echo >> /etc/hosts
	cat /etc/hosts.backup >> /etc/hosts
}

#---------- PRINT USERS INFO----------#
print_new_info()
{
	print_title "---------------------------"
	print_error "$USER_R ($(id -u $USER_R)) --> $PASS_R" 
	print_ok "$USER_N ($(id -u $USER_N)) --> $PASS_N"
	print_noch "HOSTNAME --> $HOSTNAME"
	print_title "---------------------------"
	#read -n 1
}

#---------- DELETE PI USER ----------#
delete_pi_user()
{
	if [ "$deletepi" -eq 1 ]; then
		print_info "Deleting pi user..."
		deluser --remove-home pi
		userdel -r -f pi
	fi
}

init314_replace()
{
	sed -i "s/$1.*/$2/g" $3
}

init314_delline()
{
	sed -i "/$1/d" $2 
}

#----------------------------------------------------------------------
main "$@"
#clear 
exit 0
#----------------------------------------------------------------------