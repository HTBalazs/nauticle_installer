#!/bin/sh

# Set OS variable and install opengl if linux system is detected
OS="Linux"
if [ "$(uname)" = "Darwin" ]; then
    brew install wget
    OS="Mac"
elif [ $OS = "Linux" ]; then
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
BIN_DIR="${INSTALL_DIR}/lemps/bin/$OS"
if [ "$OS" = "Mac" ]; then
	sudo printf "\nexport PATH=\${PATH}:$BIN_DIR\n" >> ~/.bash_profile
    alias brc='source ~/.bashrc'
    sudo chmod -R 777 ${INSTALL_DIR}
elif [ "$OS" = "Linux" ]; then
	sudo printf "\nexport PATH=\${PATH}:$BIN_DIR\n" >> ~/.bashrc
	alias brc='source ~/.bashrc'
	sudo chmod -R 777 ${INSTALL_DIR}
fi

# Generate script file to run pmsimple (this file is optional and probably useful only when using pmsimple through ssh)
sudo rm -f start.sh
sudo touch start.sh
sudo chmod 777 start.sh
printf "#!/bin/sh\nexecutable=$BIN_DIR/pmsimple\n" >> start.sh
printf "sudo \$executable" >> start.sh
