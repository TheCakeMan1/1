#!/bin/bash
#https://github.com/nyanmisaka/ffmpeg-rockchip/wiki/Compilation ffmpeg
#https://github.com/Qengineering/YoloV5-NPU-Rock-5 rknpu2
if [[ $EUID -ne 0 ]]; then
	echo "\033[31mONLY SUDO\033[0m"
	exit 1
fi
echo "Install Ffmpeg with mpp and rga"
sudo apt -y install git meson cmake pkg-config gcc libdrm-dev wget libx265-dev libx264-dev libsecret-1-dev python3-pip
echo "###############################"
echo -e "______________\033[31mmpp\033[0m______________"
echo "###############################"
mkdir -p ~/dev && cd ~/dev
git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
mkdir -p ./rkmpp && cd ./rkmpp
mkdir rkmpp_build && cd ./rkmpp_build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_TEST=OFF ..
make -j $(nproc)
make install
if [ $? -ne 0 ]; then
	echo -e "\033[31mmpp not install\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mmpp installed\033[0m";
fi
sleep 2

echo "###############################"
echo -e "______________\033[31mrga\033[0m______________"
echo "###############################"
mkdir -p ~/dev && cd ~/dev
git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
meson setup rkrga rkrga_build --prefix=/usr --libdir=lib --buildtype=release --default-library=shared -Dcpp_args=-fpermissive -Dlibdrm=false -Dlibrga_demo=false
meson configure rkrga_build
ninja -C rkrga_build install
if [ $? -ne 0 ]; then
	echo -e "\033[31mrga not install\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mrga installed\033[0m";
fi
sleep 2

echo "###############################"
echo -e "______________\033[31mffmpeg\033[0m______________"
echo "###############################"
mkdir -p ~/dev && cd ~/dev
git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
cd ffmpeg
./configure --prefix=/usr --enable-gpl --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga --enable-libx265
make -j $(nproc)
make install
if [ $? -ne 0 ]; then
	echo -e "\033[31mffmpeg not install\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mffmpeg installed\033[0m";
fi
sleep 2

echo "###############################"
echo -e "______________\033[31mrknpu2\033[0m______________"
echo "###############################"
mkdir -p ~/dev && cd ~/dev
git clone --depth=1 https://github.com/rockchip-linux/rknpu2.git
cd rknpu2/runtime/RK3588/Linux/librknn_api/include
sudo cp ./rknn* /usr/local/include
cd ~/dev
cd rknpu2/runtime/RK3588/Linux/librknn_api/aarch64
sudo cp ./lib* /usr/local/lib
if [ $? -ne 0 ]; then
	echo -e "\033[31mrknpu2 not install\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mrknpu2 installed\033[0m";
fi
sleep 2

echo "###############################"
echo -e "______________\033[31mlibrga\033[0m______________"
echo "###############################"
mkdir -p ~/dev && cd ~/dev
git clone --depth=1 https://github.com/airockchip/librga.git
cd librga/include
sudo cp ./*.h /usr/local/include
cd ~/dev
cd librga/libs/Linux/gcc-aarch64
sudo cp ./lib* /usr/local/lib
if [ $? -ne 0 ]; then
	echo -e "\033[31mlibrga not install\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mlibrga installed\033[0m";
fi

echo "###############################"
echo -e "______________\033[31mconfig python\033[0m______________"
echo "###############################"
pip install rknn_toolkit_lite2-2.2.0-cp310-cp310-linux_aarch64.whl
if [ $? -ne 0 ]; then
	echo -e "\033[31mno config python\033[0m";
	exit 1;
else 
	echo -e "\033[0;32m\033[102mok\033[0m";
fi

#g++ -g main.cpp postprocess.h postprocess.cpp -o ../bin/Release/main -lavcodec -lavformat -lavutil -lstdc++ -lopencv_core -lopencv_videoio -lopencv_highgui -lopencv_imgproc -lrga -lrknn_api

