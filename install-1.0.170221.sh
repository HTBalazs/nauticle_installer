#!/bin/sh

# Set OS variable and install opengl if linux system is detected
if [ "$(uname)" == "Darwin" ]; then
    brew install wget
    OS="Mac"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    OS="Linux"
    sudo apt-get update 
	sudo apt-get install build-essential
	sudo apt-get install freeglut3-dev
fi

INSTALL_DIR=$PWD

wget http://www.vtk.org/files/release/7.0/VTK-7.0.0.zip
sudo unzip VTK-7.0.0.zip -d /usr/local/
cd /usr/local/VTK-7.0.0
sudo cmake .
sudo make

cd $INSTALL_DIR
# Download and unzip the necessary files
# Common utils
wget https://bitbucket.org/lempsproject/commonutils/downloads/commonutils-1.0.170221.zip
sudo unzip commonutils-1.0.170221.zip
sudo chmod -R 777 commonutils
rm commonutils-1.0.170221.zip
# Prolog
wget https://bitbucket.org/lempsproject/prolog/downloads/prolog-1.0.170221.zip
sudo unzip prolog-1.0.170221.zip
sudo chmod -R 777 prolog
rm prolog-1.0.170221.zip
# HandyXML
wget https://bitbucket.org/lempsproject/handyxml/downloads/handyxml-1.0.170221.zip
sudo unzip handyxml-1.0.170221.zip
sudo chmod -R 777 handyxml
rm handyxml-1.0.170221.zip
# LEMPS
wget https://bitbucket.org/lempsproject/lemps/downloads/lemps-1.0.170221.zip
sudo unzip lemps-1.0.170221.zip
sudo chmod -R 777 lemps
rm lemps-1.0.170221.zip

# Compile, build, install the dependencies and the lemps executable (pmsimple) itself
cd commonutils
sudo cmake .
sudo cmake .
sudo make install
cd ..
 
cd prolog
sudo cmake .
sudo cmake .
sudo make install
cd ..
 
cd handyxml
sudo cmake .
sudo cmake .
sudo make install
cd ..
 
cd lemps
sudo cmake .
sudo cmake .
sudo mkdir bin
sudo mkdir bin/Linux
sudo mkdir bin/Mac
sudo make
cd ..

# Add pmsimple to the environmental PATH variable
export PATH=$PATH:/Users/admin/Dropbox/HomeProjects/bitbucket/LEMPS/bin/$OS
if [ $OS == "Darwin" ]; then
    source ~/.bash_profile
elif [ $OS == "Linux" ]; then
    source ~/.bashrc
fi

# Generate script file to run pmsimple (this file is optional and probably useful only when using pmsimple through ssh)
sudo rm -f start.sh
sudo touch start.sh
sudo chmod 777 start.sh
printf "#!/bin/sh\n" >> start.sh
printf "executable=" >> start.sh
printf $INSTALL_DIR >> start.sh
printf "/lemps/bin/" >> start.sh
printf $OS >> start.sh
printf "pmsimple\n" >> start.sh
printf "sudo \$executable" >> start.sh
