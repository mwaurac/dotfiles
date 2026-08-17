
# set PATH so it includes user's private bin if it exists
if [ -d /home/mwaura/bin ] ; then
    PATH=/home/mwaura/bin:/home/mwaura/.cargo/bin:/home/mwaura/.opencode/bin:/home/mwaura/.nvm/versions/node/v24.18.1/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/games
fi

# set PATH so it includes user's private bin if it exists
if [ -d /home/mwaura/.local/bin ] ; then
    PATH=/home/mwaura/.local/bin:/home/mwaura/.cargo/bin:/home/mwaura/.opencode/bin:/home/mwaura/.nvm/versions/node/v24.18.1/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/games
fi
. /home/mwaura/.cargo/env


# Added by Toolbox App
export PATH=/home/mwaura/.cargo/bin:/home/mwaura/.opencode/bin:/home/mwaura/.nvm/versions/node/v24.18.1/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/home/mwaura/bin:/home/mwaura/.local/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/games:/home/mwaura/.local/share/JetBrains/Toolbox/scripts


if [[ -r /etc/profile.d/flatpak.sh ]]; then
    source /etc/profile.d/flatpak.sh
fi
