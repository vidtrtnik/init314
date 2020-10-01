# init314
Initialize your Raspberry Pi

## Introduction
<b>init314</b> is a powerful script that can quickly configure your Raspberry Pi and makes it more secure, stable and usable.

I believe that since Raspberry Pi 3B(+) and 4B have launched, these small computers can now serve as a replacement for a full desktop computer. Default Raspbian desktop installation is excellent for education purposes, programming and media playback. But its default configuration may not be appropriate for an advanced desktop user. <b>init314</b> attempts to fix this by configuring the hardware and software and provides options for quick customization of the Raspberry Pi to your liking. The script easily creates new root and non-root users, changes hostname, sets GPU memory allocation, installs new software packages and does many more things related to the usability and security of the system. The script was tested on a 32-bit Raspbian (2019) and on 32-bit Raspberry Pi OS (2020).


## Usage example
I recommend to run <b>init314</b> after the default installation of Raspberry Pi OS with desktop. Root is required to run this script.

Usage: <code class="language-plaintext highlighter-rouge">./init314.sh [--addrootuser="username;password"] [--adduser="username;password"] [--autologin="username"] [--hostname="hostname"] [--delpi] [--vncpass="password"] [--enablevnc] [--fixnoircam] [--aptinstall] [--disableswap] [--gpumem="size"]</code>

## Configuring the script
### Adding users
<b>init314</b> can add two types of users: normal (standard) and root (admin) user. Root user is in a sudo group. You can specify usernames and passwords for normal and root account. See the list below.
- For root account: <code class="language-plaintext highlighter-rouge">--addrootuser="<i>username</i>;<i>password</i>"</code>
- For normal account: <code class="language-plaintext highlighter-rouge">--adduser="<i>username</i>;<i>password</i>"</code>

Parameters <code class="language-plaintext highlighter-rouge">username</code> and <code class="language-plaintext highlighter-rouge">password</code>, separated by semicolon, are optional. If they are not provided, then the username and password are automatically generated.

### Changing hostname
You can pass parameter <code class="language-plaintext highlighter-rouge">--hostname="<i>newhostname</i>"</code> to change the hostname of your Raspberry Pi. If this parameter is not provided, then <i>raspberrypi</i> is used as the hostname.

### Changing GPU memory
You can pass parameter <code class="language-plaintext highlighter-rouge">--gpumem="<i>gpumemory</i>"</code> to change the available video memory of your Raspberry Pi (in Megabytes).

### Delete pi user
If you pass <code class="language-plaintext highlighter-rouge">--delpi</code>, then the default <i>pi</i> user will be deleted, along with the pi home folder. <b>Use with caution!</b>

### Home folders
Additional files and folders for users can be put to <code class="language-plaintext highlighter-rouge">./home_folders/user_r/</code> and <code class="language-plaintext highlighter-rouge">./home_folders/user_n/</code>, which will be copied to appropriate home directiories for previously added root and normal user.

### Environment variables
Put additional environment variables to: <code class="language-plaintext highlighter-rouge">./env_vars/environment.txt</code>. <b>init314</b> will append these variables to /etc/environment by default.

### Hosts file
Put your customized hosts file into the <code class="language-plaintext highlighter-rouge">./hosts</code> folder. <b>init314</b> will append the contents of the file to the /etc/hosts.

### VNC
Parameter <code class="language-plaintext highlighter-rouge">--enablevnc</code> enables VNC server in service mode on startup. <b>init314</b> configures password for VNC server in service mode by default.  
Pass parameter <code class="language-plaintext highlighter-rouge">--vncpass="<i>password</i>"</code> to specify the VNC password yourself. If this parameter is not provided, then it will be randomly generated.

### Auto login for specific user
By default, no user is set to login automatically on boot. If you wish to specify a user, which will be loged in automatically on boot, then pass parameter <code class="language-plaintext highlighter-rouge">--autologin="<i>username</i>"</code>.

### NoIR Camera v2 Fix
Pass the parameter <code class="language-plaintext highlighter-rouge">--fixnoircam</code> to fix some issues with the original Raspberry Pi NoIR Camera v2 output.

### Installing additional packages
Pass the parameter <code class="language-plaintext highlighter-rouge">--aptinstall</code> to install additional software packages, specified in file <code class="language-plaintext highlighter-rouge">./apt_install/packages.txt</code>. The script will also perform a software update and upgrade.

### Disable swap
The parameter <code class="language-plaintext highlighter-rouge">--disableswap</code> disables swap file on the Raspberry Pi OS. This should reduce the microSD card wear, but can lead to stability problems and data loss, especially on low RAM (<2GB) Raspberry Pi's.

### Desktop and theme settings
TODO

## Other changes
### Audio
- The audio output is set to ANALOG.

### Config.txt
- Enables HDMI force hotplug.
- Disables overscan

## TODO
- Build GUI
- Include custom themes

<b>Current version: 1.2</b>
