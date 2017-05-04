#!/bin/sh

# Versions of nauticle and its dependencies
NAUTICLE_version="1.0.170221"
VTK_version="7.0.0"
CU_VERSION="1.0.170221"
PL_version="1.0.170221"
HX_version="1.0.170502"

# Set current directory to install directory.
INSTALL_DIR=$PWD
sudo chmod -R 777 ${INSTALL_DIR}

# Set OS variable (assume linux)
OS="Linux"
if [ "$(uname)" = "Darwin" ]; then
# if mac, install wget, and cmake
    brew install wget
   	brew install cmake
    OS="Mac"
elif [ $OS = "Linux" ]; then
# if linux, install opengl and cmake
    sudo apt-get update
	sudo apt-get --yes --force-yes install build-essential
	sudo apt-get --yes --force-yes install freeglut3-dev
	sudo apt-get --yes --force-yes install cmake
fi

# Install proper version of VTK library
wget http://www.vtk.org/files/release/7.0/VTK-$VTK_version.zip
sudo unzip VTK-$VTK_version.zip -d /usr/local/
cd /usr/local/VTK-$VTK_version
sudo cmake .
sudo make

# Go to install directory
cd $INSTALL_DIR

# Download and unzip the required packages
# Common utils
wget https://bitbucket.org/nauticleproject/commonutils/downloads/commonutils-$CU_VERSION.zip
sudo unzip commonutils-$CU_VERSION.zip
sudo chmod -R 777 commonutils
rm commonutils-$CU_VERSION.zip
# Prolog
wget https://bitbucket.org/nauticleproject/prolog/downloads/prolog-$PL_version.zip
sudo unzip prolog-$PL_version.zip
sudo chmod -R 777 prolog
rm prolog-$PL_version.zip
# HandyXML
wget https://bitbucket.org/nauticleproject/handyxml/downloads/handyxml-$HX_version.zip
sudo unzip handyxml-$HX_version.zip
sudo chmod -R 777 handyxml
rm handyxml-$HX_version.zip
# nauticle
wget https://bitbucket.org/nauticleproject/nauticle/downloads/nauticle-$NAUTICLE_version.zip
sudo unzip nauticle-$NAUTICLE_version.zip
sudo chmod -R 777 nauticle
rm nauticle-$NAUTICLE_version.zip

# Install the dependencies and the nauticle executable (nauticle) itself
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

# Set directory name for executable
BIN_DIR="${INSTALL_DIR}/nauticle/bin/$OS"
cd nauticle
sudo cmake .
sudo cmake .
sudo mkdir $BIN_DIR
sudo make
cd ..

# Add BIN_DIR to the environmental PATH variable
if [ "$OS" = "Mac" ]; then
	sudo printf "\nexport PATH=\${PATH}:$BIN_DIR\n" >> ~/.bash_profile
    alias brc='source ~/.bash_profile'
elif [ "$OS" = "Linux" ]; then
	sudo printf "\nexport PATH=\${PATH}:$BIN_DIR\n" >> ~/.bashrc
	alias brc='source ~/.bashrc'
fi

# Generate script file to run nauticle
# (this file is optional and probably useful only when using Nauticle through ssh)
sudo rm -f start.sh
sudo touch start.sh
sudo chmod 777 start.sh
printf "#!/bin/sh\nshift\nexecutable=$BIN_DIR/nauticle\n" >> start.sh
printf "sudo \$executable \"\$@\"" >> start.sh
