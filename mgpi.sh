#!/bin/bash

#firewall and system update

sudo ufw enable

sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf

sudo pacman -Syu vim ttf-fira-code qbittorrent mpv steam pavucontrol flameshot htop gnome-shell-extension-pop-shell postgresql docker docker-compose kitty
 
#symbolic link for snap and install apps

sudo ln -s /var/lib/snapd/snap /snap

snap info code
sudo snap install code --classic

snap info slack
sudo snap install slack --classic 

snap info node
sudo snap install node --classic

snap info beekeeper-studio
sudo snap install beekeeper-studio

snap info insomnia
sudo snap install insomnia

echo 'Yarn'
sudo npm i yarn -g
# echo 'Vercel CLI'
# sudo yarn global add vercel
# echo 'Heroku CLI'
# sudo yarn global add heroku
# echo 'Typescript <3'
# sudo yarn global add typescript

echo 'Vercel CLI'
sudo npm i vercel -g
echo 'Heroku CLI'
sudo npm i heroku -g
echo 'Typescript <3'
sudo npm i typescript -g

#setup default text editor with zsh

shell=".zshrc"

read -p "default text editor : " EDITOR

echo export EDITOR=$EDITOR >> $shell

# setup gitConfig and set my personal git aliases

read -p 'git name :' name
read -p 'confirm git name : ' confirm_name
 
while [ $name != $confirm_name ]
do
  read -p 'names do not match , type again : ' name
  read -p 'confirm name : ' confirm_name
done

read -p 'email for generate git SSH key : ' email
read -p 'confirm email : ' confirm_email

while [ $email != $confirm_email ]
do
  read -p 'emails do not match , type again : ' email
  read -p 'confirm email : ' confirm_email
done

echo "[user]
	name = $name
	email = $email
[alias]
	s = !git status -s
	a = !git add -A
	c = !git commit -m
	l = !git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all
	co = !git checkout" > ~/.gitconfig

#change the CAPSLOCK for the CTRL key and mpv binds
HOME=/home/$(logname)

cd $HOME/.config

mkdir mpv
chmod 777 mpv

cd mpv

echo "# increase subtitle font size
ALT+k add sub-scale +0.1

# decrease subtitle font size
ALT+j add sub-scale -0.1" > input.conf
chmod 777 input.conf

cd $HOME

mkdir .Scripts
chmod 777 .Scripts

cd .Scripts

echo "clear lock
clear control
add control = Caps_Lock Control_L Control_R
keycode 66 = Control_L Caps_Lock NoSymbol NoSymbol" > .Xmodmap
chmod 777 .Xmodmap

cd $HOME/.config/autostart

echo "[Desktop Entry]
Type=Application
Name=modmap
Exec=$HOME/.Scripts/modmap.sh" > modmap.desktop
chmod 777 modmap.desktop

cd $HOME/.Scripts

echo "#!/bin/bash
sleep 1s
xmodmap .Xmodmap" > modmap.sh
chmod 777 modmap.sh

xmodmap $HOME/.Scripts/.Xmodmap

curl -O -s https://raw.githubusercontent.com/fabioalmeida08/weatherSH/main/weather

cd $HOME

echo 'alias clima="bash $HOME/.Scripts/weather"' >> $shell
# generate SSH key to use on gitHub and passing the key to the clipboard

ssh-keygen -t ed25519 -C $email
xclip -sel c < $HOME/.ssh/id_ed25519.pub

echo SSH key copied to Clipboard
echo
echo https://github.com/settings/keys
echo

# docker config

sudo systemctl enable --now docker.service

sudo groupadd docker

sudo usermod -aG docker $USER



# postgresql config

echo "en_US.UTF-8 UTF-8" | sudo tee /etc/locale.gen
sudo locale-gen

sudo su -c "
initdb --locale en_US.UTF-8 -D /var/lib/postgres/data
" postgres

sudo systemctl start postgresql
#sudo systemctl enable postgresql
#sudo systemctl enable --now postgresql.service

read -p 'postgre user name : ' postgre_user_name
read -p 'confirm postgre user name : ' confirm_postgre_user_name
 
while [ $postgre_user_name != $confirm_postgre_user_name ]
do
  read -p 'user names do not match , type again : ' postgre_user_name
  read -p 'confirm user name : ' confirm_postgre_user_name
done

read -p 'postgre password : ' postgre_password
read -p 'confirm postgre password : ' confirm_postgre_password
 
while [ $postgre_password != $confirm_postgre_password ]
do
  read -p 'passwords do not match , type again : ' postgre_password
  read -p 'confirm password : ' confirm_postgre_password
done

cd $HOME

sudo su -c "
psql -c \"CREATE USER $postgre_user_name SUPERUSER CREATEROLE CREATEDB PASSWORD '$postgre_password' \"
psql -c \"CREATE DATABASE $postgre_user_name \"
" postgres 

#keyboard shortcuts


echo "[org/gnome/settings-daemon/plugins/media-keys]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']
screensaver=['<Super>x']
screenshot=@as []

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Alt>Return'
command='kitty'
name='Terminal'

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
binding='Print'
command='flameshot gui'
name='Print'

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
binding='<Super>v'
command='pavucontrol'
name='Pavu control'" > $HOME/.config/dconf/keybinds.conf

dconf load / < $HOME/.config/dconf/keybinds.conf

newgrp docker