#!/bin/bash

# init314
# version 1.2

if (( $EUID != 0 )); then
	echo "Run this script as root!"
	exit 1
fi

source ./tools/prints.sh
source ./tools/rsgen.sh

adduserconf="/etc/adduser.conf"
configtxt="/boot/config.txt"
group="/etc/group"
lightdmconf="/etc/lightdm/lightdm.conf"
dropcaches="/proc/sys/vm/drop_caches"
sysctlconf="/etc/sysctl.conf"

vncpassw=""
gpumem=-1

adduser=0
addrootuser=0
setaudio=0
fixnoircam=0
sethostname=0
audioout=1 #analog
deletepi=0
enablevnc=0
aptinstall=0
disableswap=0

autologin_user=""

USER_R=""
USER_N=""
PASS_R=""
PASS_N=""
HOSTNAME=""

main()
{
	print_title "Init 314"

	check_arguments "$@"

	add_users
	configure_lightdm

	edit_configtxt
	setup_audio
	append_environment

	setup_vnc

	set_hostname
	append_hosts

	delete_pi_user
	set_dir_mode

	apt_install
	disable_swap

	print_new_info
	print_info "Exiting..."
	echo
	return 0
}

#---------- CHECK ARGUMENTS ----------#
check_arguments()
{
    while (( "$#" )); do
        arg=$(echo $1 | cut -d'=' -f1)
        parameter=$(echo $1 | cut -d'=' -f2)

        case "$arg" in

            "--addrootuser")
								addrootuser=1
                username=$(echo "$parameter" | cut -d';' -f1)
                password=$(echo "$parameter" | grep ";" | cut -d';' -f2)
                USER_R="$username"
                PASS_R="$password"
								if [[ "$parameter" == "--addrootuser" ]]; then
									USER_R=""
	                PASS_R=""
								fi
                ;;

            "--adduser")
								adduser=1
                username=$(echo "$parameter" | cut -d';' -f1)
                password=$(echo "$parameter" | grep ";" | cut -d';' -f2)
                USER_N="$username"
                PASS_N="$password"
								if [[ "$parameter" == "--adduser" ]]; then
									USER_N=""
	                PASS_N=""
								fi
                ;;

            "--hostname")
								sethostname=1
                HOSTNAME="$parameter"
                ;;

						"--setaudio")
								setaudio=1
		            #audioout="$parameter"
		            ;;

            "--autologin")
                autologin_user="$parameter"
                ;;

            "--vncpass")
                vncpassw="$parameter"
                ;;

            "--delpi")
                deletepi=1
                ;;

            "--enablevnc")
                enablevnc=1
                ;;

	    			"--gpumem")
                gpumem="$parameter"
                ;;

						"--fixnoircam")
								fixnoircam=1
								;;

						"--aptinstall")
		            aptinstall=1
		            ;;

						"--disableswap")
				        disableswap=1
				        ;;

            *)
                echo "Unknown argument: $arg"
                ;;

            esac

        shift
    done
}

add_users()
{
	if [[ "$adduser" -eq 1 ]]; then
		if [[ -z "$USER_N" ]] || [[ "$USER_N" == "" ]]; then USER_N="$(rsgen_al 4 lc)"; fi
		if [[ -z "$PASS_N" ]] || [[ "$PASS_N" == "" ]]; then PASS_N="$(rsgen_alnum 8)"; fi
		print_info "Creating normal user \"$USER_N\""
		create_user $USER_N $PASS_N
	fi

	if [[ "$addrootuser" -eq 1 ]]; then
		if [[ -z "$USER_R" ]] || [[ "$USER_R" == "" ]]; then USER_R="$(rsgen_al 4 lc)"; fi
		if [[ -z "$PASS_R" ]] || [[ "$PASS_R" == "" ]]; then PASS_R="$(rsgen_alnum 8)"; fi
		print_info "Creating root user \"$USER_R\""
		create_user $USER_R $PASS_R
		set_root_user $USER_R
	fi

	copy_to_home_dirs
}

#---------- CREATE USER ----------#
create_user()
{
	adduser --disabled-password --gecos "" $1

	print_info "Setting password for \"$1\"..."
	echo "$1:$2" | sudo chpasswd
}

#--------- SET DIR_MODE ---------#
set_dir_mode()
{
	print_info "Setting DIR_MODE..."
	init314_replace "DIR_MODE=0755" "DIR_MODE=0750" $adduserconf
}

#---------- SET ROOT ----------#
set_root_user()
{
	print_error "Adding root user \"$1\" to additional groups..."
	usermod -a -G sudo,netdev,audio,video,bluetooth $1
}

#---------- COPY TO HOME DIRECTORIES ----------#
copy_to_home_dirs()
{
	if [[ "$adduser" -eq 1 ]]; then
		print_info "Copying files for user \"$USER_N\" from ./home_folders/user_n"
		cp -r ./home_folders/user_n/. /home/$USER_N/
		chown -R $USER_N:$USER_N /home/$USER_N
	fi

	if [[ "$addrootuser" -eq 1 ]]; then
		print_info "Copying files for user \"$USER_R\" from ./home_folders/user_r"
		cp -r ./home_folders/user_r/. /home/$USER_R/
		chown -R $USER_R:$USER_R /home/$USER_R
	fi
}

#---------- LIGHTDM ----------#
configure_lightdm()
{
  if [[ ! -z "$autologin_user" ]] && [[ "$autologin_user" != "" ]]; then
		print_info "Setting automatic login for user $autologin_user..."
		init314_replace "autologin-user=pi" "autologin-user=$autologin_user" $lightdmconf
	fi
}

#---------- CONFIG.TXT ----------#
edit_configtxt()
{
	print_info "Editing config.txt..."
	init314_replace "#hdmi_force_hotplug=1" "hdmi_force_hotplug=1" $configtxt
	init314_replace "#disable_overscan=1" "disable_overscan=1" $configtxt


	if [[ "$gpumem" -gt 0 ]]; then echo "gpu_mem=$gpumem" >> $configtxt; fi
	if [[ "$fixnoircam" -eq 1 ]]; then echo "awb_auto_is_greyworld=1" >> $configtxt; fi
}

#---------- AUDIO ----------#
setup_audio()
{
	if [[ "$setaudio" -eq 0 ]]; then return 0; fi

	print_info "Setting audio output to ANALOG..."
	amixer cset numid=3 "$audioout"
}

#---------- ENVIRONMENT ----------#
append_environment()
{
	print_info "Appending additional environment variables..."
	cat ./env_vars/environment.txt >> /etc/environment
}

#---------- VNC ----------#
setup_vnc()
{
	if [[ "$enablevnc" -eq 0 ]]; then return 0; fi

  if [[ -z "$vncpassw" ]] || [[ "$vncpassw" == "" ]]; then vncpassw="$(rsgen_alnum 8)"; fi
  vncpassw_string="$vncpassw/\n$vncpassw/\n/\n"

	print_info "Setting VNC password..."
	printf $vncpassw_string | vncpasswd -service

	print_info "Enabling VNC service..."
	sudo systemctl enable vncserver-x11-serviced.service
}

#---------- HOSTNAME ----------#
set_hostname()
{
	if [[ "$sethostname" -eq 0 ]]; then return 0; fi

	print_info "Setting new hostname \"$HOSTNAME\"..."
	if [[ -z "$HOSTNAME" ]] || [[ "$HOSTNAME" == "" ]]; then HOSTNAME="raspberrypi"; fi
	init314_replace "$(hostname)" "$HOSTNAME" /etc/hosts
	echo $HOSTNAME > /etc/hostname
}

#---------- HOSTS ----------#
append_hosts()
{
	print_info "Creating backup of hosts files..."
	cp /etc/hosts /etc/hosts.backup
	cp ./hosts/hosts /etc/hosts
	print_info "Appending hosts files..."
	echo >> /etc/hosts
	cat /etc/hosts.backup >> /etc/hosts
}

#---------- INSTALL PACKAGES ----------#
apt_install()
{
	if [[ "$aptinstall" -eq 0 ]]; then return 0; fi

	print_info "Updating system..."
	apt update && apt upgrade -y

	print_info "Installing packages"
	cat "./apt_install/packages.txt" | xargs apt install -y
}

# --------- DISABLE SWAP ----------#
disable_swap()
{
	if [[ "$disableswap" -eq 0 ]]; then return 0; fi

	print_info "Disabling swap..."
	dphys-swapfile swapoff
	dphys-swapfile uninstall
	systemctl disable dphys-swapfile

  echo "vm.swappiness = 0" | sudo tee -a $sysctlconf
	echo 1 | sudo tee $dropcaches

	free -h
}

#---------- PRINT USERS INFO----------#
print_new_info()
{
	print_ok "---------------------------"
	if [[ "$addrootuser" -eq 1 ]]; then print_error "Root user: $USER_R ($(id -u $USER_R)) --> $PASS_R"; fi
	if [[ "$adduser" -eq 1 ]]; then print_ok "Normal user: $USER_N ($(id -u $USER_N)) --> $PASS_N"; fi
	if [[ "$sethostname" -eq 1 ]]; then print_noch "HOSTNAME --> $HOSTNAME"; fi
	if [[ "$enablevnc" -eq 1 ]]; then print_noch "VNC password --> $vncpassw"; fi
	print_ok "---------------------------"
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
