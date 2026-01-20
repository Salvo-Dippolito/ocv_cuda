#!/bin/bash
set -e
YE='\033[0;33m' # Yellow
NC='\033[0m' # No Color
echo -e $YE

echo "*************************************************************************"
echo "********************** Setting up user **********************************"
echo "*************************************************************************"
echo -e $NC
# --------------------- user configuration ---------------------

# Ensure UID and USERNAME are set
if [[ -z "$uid" || -z "$username" ]]; then
    echo "Error: uid or username is not set. Exiting."
    exit 1
fi

echo "Checking for existing UID: ${uid}"

# Get the existing user for UID 1000
existing_user=$(getent passwd "${uid}" | cut -d: -f1)

if [ -n "$existing_user" ]; then
    echo "UID ${uid} already exists and belongs to user: ${existing_user}"
	userdel ${existing_user}

fi

# Configure internal user IDs as the host user
groupadd -g ${gid:-1000} ${username}
useradd --create-home ${username} \
    --uid ${uid:-1000} --gid ${gid:-1000} \
    --shell /bin/bash

# Disable password for new user creation ${username}
passwd -d ${username}
echo "${username} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${username}
chmod 0440 /etc/sudoers.d/${username}
echo "Recursively changing ownership of /home/${username} to ${uid}:${gid}"
chown ${uid}:${gid} -R /home/${username}
# ssh-keygen -A

# create missing groups spi i2c gpio
echo "Creating missing groups spi i2c gpio"
groupadd -f -g 13 i2c
groupadd -f -g 20 gpio
groupadd -f -g 44 spi

# Add user to groups
echo "Adding user to groups"
usermod -aG sudo ${username}
usermod -aG adm ${username}
usermod -aG dialout ${username}
usermod -aG cdrom ${username}
usermod -aG video ${username}
usermod -aG gpio ${username}
usermod -aG spi ${username}
usermod -aG i2c ${username}

echo "Setting up user environment variables by modifying .bashrc"

if (( RANDOM % 2 )); then
    CONTAINER_NAME="(╯°□ °)╯︵ ┻━┻"
else
    CONTAINER_NAME=" ( ͡° ͜ʖ ͡°) "
fi


cat >> /home/${username}/.bashrc << EO_BASHRC
# check if the current directory has git active, if so prompt current branch name
parse_git_branch() {
git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

LS_COLORS='rs=0:di=1;35:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

if (( RANDOM % 2 )); then
    CONTAINER_NAME="(╯°□ °)╯︵ ┻━┻"
else
    CONTAINER_NAME=" ( ͡° ͜ʖ ͡°) "
fi
PS1="\[\e[1m\e[38;5;107m\]\u\[\e[0m\e[38;5;250m\]@${CONTAINER_NAME:-dodbob} \W \$(parse_git_branch)\$\[\e[0;97m\] "

# TODO: investigate if needed
export BUILDDIR=/tmp

export MAKEFLAGS="-j\$(nproc) \$MAKEFLAGS"
export PATH="\$HOME/.local/bin:\$PATH"
export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:\$LD_LIBRARY_PATH"
export PYTHONPATH="/usr/lib/python3/dist-packages:\$PYTHONPATH"

# alias inst='sudo apt install'
# alias search='sudo apt search'
# alias remove='sudo apt remove'
# alias clean='sudo apt-get clean'
# alias up='sudo apt update'
# alias upp='sudo apt update && sudo apt upgrade'

# alias gadd='git add'
# alias gcom='git commit'
# alias glog='git log --oneline --graph --decorate --all -5'
# alias gl='git log --oneline --all --graph --decorate'
# alias gpush='git push'
# alias gstat='git status'


# Tmux server override (in order to not overlap with host server)
# without this, when running tmux you would leave the docker's root and enter 
# your host system's root 
export TMUX_TMPDIR=/tmp/\$(whoami)-tmux
mkdir -p \$TMUX_TMPDIR

# Tmuxinator quick launcher
alias tmux-start="tmuxinator start -p"

# Fix ws directory permissions due to Docker mount (not needed in subdirectories)
# sudo chown ${username}:${username} ~/ws/*

#this is for ROS2, so commenting it:
# # ROS aliases
# alias colbu="colcon build --symlink-install --event-handler console_direct+"
# alias colcl="rm -rf build/ install/ log/
# # ROS environment setup
# source /opt/ros/${ros_distro}/setup.bash
# source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
# source /usr/share/colcon_cd/function/colcon_cd.sh
# source ${components_path}/install/local_setup.bash
# for folder in ~/ws/*; do
#     # \$(cd \${folder} && colcon build --symlink-install)
#     test -f \${folder}/install/local_setup.bash && source \${folder}/install/local_setup.bash
# done

EO_BASHRC

echo -e $YE
echo "*************************************************************************"
echo "********************** User setup completed *****************************"
echo "*************************************************************************"
echo -e $NC