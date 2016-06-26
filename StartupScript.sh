#!/bin/bash
echo "install google chrome"
sudo touch /etc/apt/sources.list.d
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list.d/google.list
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt-get update
sudo apt-get install google-chrome-stable 

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
tar zxvf serviio-1.5.2-linux.tar.gz
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
rm *.deb 

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
sudo apt-get install jq
cat /home/$(id -nu)/.config/transmission/settings.json | jq '.["download-dir"]="/home/$(id -nu)/Documents/SharedFolder"' > /home/$(id -nu)/.config/transmission/settings_copy.json
rm /home/$(id -nu)/.config/transmission/settings.json
mv /home/$(id -nu)/.config/transmission/settings_copy.json /home/$(id -nu)/.config/transmission/settings.json 

/opt/serviio/bin/serviio-console.sh 
