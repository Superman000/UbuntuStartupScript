#!/bin/bash
echo "install google chrome"
sudo touch /etc/apt/sources.list.d
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list.d/google.list
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-chrome-stable 

echo "remove firefox"
sudo apt-get purge firefox

echo "install vlc"
sudo apt-get install vlc

echo "remove totem video player"
sudo apt-get purge totem

echo "install notepadqq"
sudo add-apt-repository ppa:notepadqq-team/notepadqq
sudo apt-get update
sudo apt-get install notepadqq

echo "create and configure a shared folder"
sudo apt-get install samba
sudo smbpasswd -a $(id -nu)
mkdir /home/$(id -nu)/Documents/SharedFolder
echo "[SharedFolder]
     path = /home/$(id -nu)/Documents/SharedFolder
     available = yes
     valid_users = $(id -nu)
     read only = no
     browsable = yes
     public = yes
     writeable = yes" | sudo tee -a /etc/samba/smb.conf
sudo service smbd restart 

echo "install and configure serviio"
sudo apt-get install ffmpeg
sudo apt-get install dcraw
sudo apt-get install openjdk-8-jre
sudo useradd -r -s /bin/false serviio
mkdir -p /opt
cd /opt
sudo wget http://download.serviio.org/releases/serviio-1.5.2-linux.tar.gz
sudo tar zxvf serviio-1.5.2-linux.tar.gz
sudo rm serviio-1.5.2-linux.tar.gz
sudo ln -s serviio-1.5.2 serviio
sudo chown -R root:root serviio-1.5.2
cd serviio-1.5.2
sudo mkdir log
sudo chown -R serviio:serviio library log
cd
echo "[Unit]
Description=Serviio Media Server
After=syslog.target local-fs.target network.target

[Service]
Type=simple
User=serviio
Group=serviio
ExecStart=/opt/serviio/bin/serviio.sh
ExecStop=/opt/serviio/bin/serviio.sh -stop
KillMode=none
Restart=on-abort

[Install]
WantedBy=multi-user.target" | sudo tee -a /lib/systemd/system/serviio.service
sudo systemctl daemon-reload
sudo systemctl enable serviio
sudo systemctl start serviio

echo "install teamviewer"
sudo wget https://download.teamviewer.com/download/teamviewer_i386.deb
sudo dpkg -i *.deb
sudo apt-get -f install
sudo rm *.deb 

echo "install R and Rstudio"
echo "deb http://cran.mirror.ac.za/bin/linux/ubuntu trusty/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo add-apt-repository ppa:marutter/rdev
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install r-base
wget https://download1.rstudio.org/rstudio-0.99.902-amd64.deb
sudo dpkg -i *.deb
sudo apt-get -f install
rm *.deb 

echo "update transmission torrent client download path"
transmission-gtk &
PID=$!
sleep 5
kill $PID
echo "deb http://archive.ubuntu.com/ubuntu/ vivid main universe" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install jq
cat /home/$(id -nu)/.config/transmission/settings.json | jq '.["download-dir"]="/home/'$(id -nu)'/Documents/SharedFolder"' > /home/$(id -nu)/.config/transmission/settings_copy.json
rm /home/$(id -nu)/.config/transmission/settings.json
mv /home/$(id -nu)/.config/transmission/settings_copy.json /home/$(id -nu)/.config/transmission/settings.json 

echo "install wireless hacking tools"
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/reaver-wps/reaver-1.4.tar.gz
tar xvfz reaver-1.4.tar.gz
sudo apt-get install libpcap-dev
sudo apt-get install libsqlite3-dev
cd reaver-1.4/src
./configure
make
sudo make install
cd
sudo apt-get install aircrack-ng
rm reaver-1.4.tar.gz

echo "install eric"
sudo apt-get install eric

echo "install sci-kit learn"
sudo apt-get install build-essential python3-dev python3-setuptools
sudo apt-get install python3-numpy python3-scipy
sudo apt-get install libatlas-dev libatlas3gf-base
sudo update-alternatives --set libblas.so.3 \
    /usr/lib/atlas-base/atlas/libblas.so.3
sudo update-alternatives --set liblapack.so.3 \
    /usr/lib/atlas-base/atlas/liblapack.so.3
sudo apt-get install python-matplotlib

echo "customise launcher"
gsettings set com.canonical.Unity.Launcher favorites "['application://org.gnome.Nautilus.desktop', 'application://libreoffice-writer.desktop', 'application://libreoffice-calc.desktop', 'application://libreoffice-impress.desktop', 'application://org.gnome.Software.desktop', 'application://rstudio.desktop', 'application://gnome-terminal.desktop', 'unity://running-apps', 'application://google-chrome.desktop', 'unity://expo-icon', 'unity://devices']"

echo "run serviio management console"
/opt/serviio/bin/serviio-console.sh 
