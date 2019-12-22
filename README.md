# init314
Configures your Raspberry Pi

## Introduction
<b>init314</b> is a powerful script that quickly configures your Raspberry Pi and makes it more secure, stable and usable. I was writing this script during my first year of Master's study at the Faculty of Computer and Information Science in Ljubljana. I was also using <b>init314</b> during the final assignment at the course Image based biometry.

I believe that since Raspberry Pi 3B(+) and 4B have launched, these small computers can now serve as a replacement for a full desktop computer. Default Raspbian desktop installation is good enough for education purposes and programming, but has some security issues and some software configurations, which may not be appropriate for an average desktop user. <b>init314</b> attempts to fix these issues by creating separated user accounts, configuring audio and video, installing aditional packages and also does many other things related to security, stability and user experience... 

<b>init314</b> is appropriate for users who want to use Raspberry Pi for daily browsing the internet, listening to music, watching movies and playing some video games. It tailors the Raspberry Pi to suit your needs.

## Usage example
Root is required to run this script.

Usage: <code class="language-plaintext highlighter-rouge">./init314.sh [-userr="username;password"] [-usern="username;password"] [-hostname="newhostname"] [-deletepi]</code>

I recommend to run <b>init314</b> after the default installation of Raspbian with desktop. 

## Configuring the script
### Adding users
<b>init314</b> creates two users: normal (standard) and root (admin) user. Root user is in a sudo group. You can specify usernames and passwords for normal and root account. See the list below.
- For root account: <code class="language-plaintext highlighter-rouge">-userr="<i>username</i>;<i>password</i>"</code>
- For normal account: <code class="language-plaintext highlighter-rouge">-usern="<i>username</i>;<i>password</i>"</code>

Parameters <code class="language-plaintext highlighter-rouge">-userr</code> and <code class="language-plaintext highlighter-rouge">-usern</code> are optional. If they are not provided, user names <i>rootuser</i> and <i>normaluser</i> are used. Semicolon can separate the username and password. Value <i>password</i> specifies password for user account. If it is not provided, then the password for the user account will be randomly generated.

### Changing hostname
You can pass parameter <code class="language-plaintext highlighter-rouge">-hostname="<i>newhostname</i>"</code> to change the hostname of your Raspberry Pi. If this parameter is not provided, then <i>raspberrypi</i> is used as the hostname.

### Delete pi user
If you pass <code class="language-plaintext highlighter-rouge">-deletepi</code>, then the default <i>pi</i> user will be deleted, along with the pi home folder. <b>Use with caution.</b>

### Home folders
Additional files and folders for users can be put to <code class="language-plaintext highlighter-rouge">./home_folders/user_r/</code> and <code class="language-plaintext highlighter-rouge">./home_folders/user_n/</code>, which will be copied to appropriate home directiories for root and normal user.

### Environment variables
Put additional environment variables to: <code class="language-plaintext highlighter-rouge">./env_vars/environment.txt</code>. <b>init314</b> will append these variables to /etc/environment.

### VNC
TODO

### Desktop settings
TODO

## Other changes
### Audio
- The audio output is set to ANALOG.
### Config.txt
- Enables HDMI force hotplug. 
- Disables overscan

## TODO
