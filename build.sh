#21.04
#Installing the build dependencies
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install gcc-9 g++-9 g++-9-multilib -y
#libaries necessary for wine to run
sudo apt install  libtag1v5-vanilla:i386 libtasn1-6:i386 libthai0:i386 libtheora0:i386 \
  libtiff5:i386 libtwolame0:i386 libudev1:i386 libunwind8:i386 \
  libusb-1.0-0:i386 libuuid1:i386 libv4l-0:i386 libv4lconvert0:i386 \
  libvisual-0.4-0:i386 libvkd3d1:i386 libvorbis0a:i386 libvorbisenc2:i386 \
  libvpx6:i386 libwavpack1:i386 libwayland-cursor0:i386 libwayland-egl1:i386 \
  libwayland-server0:i386 libwebp6:i386 libwind0-heimdal:i386 libwine  \
  libwine:i386 libwrap0:i386 libxcb-render0:i386 libxcomposite1:i386 \
  libxcursor1:i386 libxdamage1:i386 libxi6:i386 libxinerama1:i386 \
  libxkbcommon0:i386 libxml2:i386 libxpm4:i386 libxrandr2:i386 \
  libxrender1:i386 libxslt1.1:i386 libxss1:i386 libxv1:i386 \
  ocl-icd-libopencl1:i386 publicsuffix -y
  

#add focal dep; install mingw and downgrade gcc
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ focal main universe"
sudo apt install gcc-mingw-w64=9.3.0-7ubuntu1+22~exp1ubuntu4 -t focal
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 20
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 20
#Verifing gcc-9 is selected
gcc -v

sudo apt-get build-dep wine -y
sudo apt install git  build-essential winbind samba cabextract -y

mkdir -p  ~/wine-dirs/wine64-build
mkdir  ~/wine-dirs/wine32-build

#Downloding wine5.6
wget https://github.com/CountOmega/wine/archive/refs/heads/master.zip
cd ~/wine-dirs
unzip ~/master.zip && mv wine-onenote-master wine-source

#Building 64-bit wine
cd ~/wine-dirs/wine64-build/
chmod +x ../wine-source/configure
chmod +x ../wine-source/tools/install-sh
../wine-source/configure --enable-win64 --disable-tests
make -j6

sudo apt-get install schroot debootstrap
sudo nano /etc/schroot/chroot.d/ubuntu_i386.conf

[ubuntu_i386]
description=Ubuntu Release 32-Bit
personality=linux32
directory=/srv/chroot/ubuntu_i386
root-users=username
type=directory
users=username

sudo mkdir -p /srv/chroot/ubuntu_i386
sudo debootstrap --variant=buildd --arch=i386 focal /srv/chroot/ubuntu_i386 http://archive.ubuntu.com/ubuntu/
schroot -c ubuntu_i386 -u root
sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list #needs rework #focal main universe
apt update && apt upgrade -y
apt install gcc-9 g++-9 g++-9-multilib gcc-mingw-w64=9.3.0-7ubuntu1+22~exp1ubuntu4 -y
apt-get build-dep wine
#Building 32-bit wine tools
mkdir ~/wine-dirs/wine32-tools
cd ~/wine-dirs/wine32-tools/
../wine-source/configure --disable-tests
make -j6
#Building 32-bit wine 
cd ~/wine-dirs/wine32-build/
PKG_CONFIG_PATH=/usr/lib ../wine-source/configure --with-wine64=../wine64-build --with-wine-tools=../wine32-tools --disable-tests
make -j6
exit
cd ~/wine-dirs/wine32-tools/
sudo make install

cd ~/wine-dirs/wine32-build/
sudo make install
cd ~/wine-dirs/wine64-build/
sudo make install

cd ~/
wget  https://github.com/Winetricks/winetricks/archive/refs/tags/20200412.zip
unzip 20200412.zip && mv winetricks-20200412 winetricks
cd ~/winetricks
sudo make install



