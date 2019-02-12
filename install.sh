#!/bin/sh
if [ $(id -u) -eq 0 ]
  then echo "Please do not run as root. I will ask for permissions when necessary."
  exit
fi
# Versions of nauticle and its dependencies
NAUTICLE_version="1.1.190131"
VTK_version="7.0.0"
CU_VERSION="1.0.190131"
PL_version="1.0.190131"
C2_version="1.0.190131"
YAMLCPP_version="0.6.0"

# Set current directory to install directory.
INSTALL_DIR=$PWD
sudo chown ${USER} ${INSTALL_DIR}

# Set OS variable (assume linux)
OS="Linux"
NUM_THREADS=4
if [ "$(uname)" = "Darwin" ]; then
# if mac, install wget, and cmake
    brew install wget
   	brew install cmake
   	brew install boost
    OS="Mac"
    NUM_THREADS=$(sysctl -n hw.ncpu)
elif [ $OS = "Linux" ]; then
	# if linux, install opengl and cmake
    sudo apt-get update
	sudo apt-get --yes --force-yes install build-essential
	sudo apt-get --yes --force-yes install freeglut3-dev
	sudo apt-get --yes --force-yes install cmake
	sudo apt-get --yes --force-yes install libboost-all-dev
	NUM_THREADS=$(nproc)
fi

echo Setting number of threads for compilation to $NUM_THREADS

# Install proper version of VTK library
wget http://www.vtk.org/files/release/7.0/VTK-$VTK_version.zip
unzip VTK-$VTK_version.zip -d ~/local/
cd ~/local/VTK-$VTK_version
cmake .
make -j${NUM_THREADS}

# Go to install directory
cd $INSTALL_DIR

# Download and unzip the required packages
PCKG_CU=commonutils_$CU_VERSION.zip
PCKG_PL=prolog_$PL_version.zip
PCKG_C2=c2c_$C2_version.zip
PCKG_NA=nauticle_$NAUTICLE_version.zip
PCKG_YM=yaml-cpp-$YAMLCPP_version.zip
wget https://bitbucket.org/BalazsToth/commonutils/downloads/$PCKG_CU
wget https://bitbucket.org/BalazsToth/prolog/downloads/$PCKG_PL
wget https://bitbucket.org/nauticleproject/c2c/downloads/$PCKG_C2
wget https://bitbucket.org/nauticleproject/nauticle/downloads/$PCKG_NA
wget https://github.com/jbeder/yaml-cpp/archive/$PCKG_YM
unzip $PCKG_CU
unzip $PCKG_PL
unzip $PCKG_NA
unzip $PCKG_YM
unzip $PCKG_C2
# sudo chmod -R 777 commonutils prolog c2c nauticle yaml-cpp-release-$YAMLCPP_version

# Install the dependencies and the nauticle executable (nauticle) itself
cd $INSTALL_DIR/commonutils
cmake .
cmake .
make install -j${NUM_THREADS}
 
cd $INSTALL_DIR/prolog
cmake .
cmake .
make install -j${NUM_THREADS}

cd $INSTALL_DIR/yaml-cpp-yaml-cpp-$YAMLCPP_version
cmake .
cmake .
sudo make -j${NUM_THREADS}
sudo make install

cd $INSTALL_DIR/c2c
cmake .
cmake .
make install -j${NUM_THREADS}

# Set directory name for executable
BIN_DIR="${INSTALL_DIR}/nauticle/bin/$OS"
cd $INSTALL_DIR/nauticle
cmake .
cmake .
mkdir $BIN_DIR
make install -j${NUM_THREADS}
cd ..

# Add BIN_DIR to the environment PATH variable
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
touch start.sh

printf "#!/bin/sh\nshift\nexecutable=$BIN_DIR/nauticle\n" >> start.sh
printf "sudo \$executable \"\$@\"" >> start.sh

# Purge temparay files
while true; do
	read -p "Do you wish to delete temporary files?" yn
		case $yn in
		    [Yy]* ) cd $INSTALL_DIR
					sudo rm -r commonutils prolog c2c yaml-cpp-yaml-cpp-$YAMLCPP_version
					sudo rm $PCKG_CU $PCKG_PL $PCKG_YM $PCKG_NA $PCKG_C2 VTK-$VTK_version.zip
					mv $BIN_DIR/nauticle $INSTALL_DIR/tmp
					sudo rm -rf nauticle
					mkdir -p "$BIN_DIR"
					mv $INSTALL_DIR/tmp $BIN_DIR/nauticle
					break;;
		    [Nn]* ) exit;;
		    * ) echo "Please answer yes or no.";;
		esac
done
