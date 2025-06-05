#!/bin/bash

# Updates
sudo apt-get update
sudo apt-get upgrade
sudo apt-get upgrade ubuntu-drivers-common

# Required packages
sudo apt install virtualbox-guest-utils virtualbox-guest-x11

sudo apt install python-is-python3
sudo apt install vim vim-gtk3
sudo apt install git
sudo apt install gh

sudo apt install iverilog gtkwave
sudo apt install python3-pip
sudo apt install python3.12-venv
python -m venv ~/wish_venv

source ~/wish_venv/bin/activate
pip install cocotb
deactivate

cd ~/Downloads
wget -O vscode.deb https://vscode.download.prss.microsoft.com/dbazure/download/stable/258e40fedc6cb8edf399a463ce3a9d32e7e1f6f3/code_1.100.3-1748872405_amd64.deb
sudo apt install ./vscode.deb

wget -O verilog-hdl-code-ext.vsix.gz https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mshr-h/vsextensions/VerilogHDL/1.16.0/vspackage
gunzip verilog-hdl-code-ext.vsix.gz
code --install-extension verilog-hdl-code-ext.vsix

sudo apt install libreoffice

RISCV_INSTALL_PATH="/opt/riscv"
cd ~/Downloads
sudo apt-get install autoconf automake autotools-dev curl python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build cmake libglib2.0-dev libslirp-dev 
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive

PATH="$PATH:$RISCV_INSTALL_PATH/bin"
./configure --prefix=$RISCV_INSTALL_PATH
gmake -sj2

LINE="export PATH=\"$RISCV_INSTALL_PATH/bin:\$PATH\""
if !(grep -Fxq "$LINE" ~/.bashrc); then
	echo "$LINE" >> ~/.bashrc
fi

# Setting timezone
sudo timedatectl set-timezone Asia/Kolkata

# Setting Dash icons
new_favs="['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'code.desktop']"
gsettings set org.gnome.shell favorite-apps "$new_favs"


