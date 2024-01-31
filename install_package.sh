#!/bin/bash

# The package to be installed
install_package=$1

# Create a directory to store the downloaded packages
mkdir -p packages

# If the package to be installed is Visual Studio Code, add the repository
if [ "$install_package" = "code" ]; then
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
fi

# If the package to be installed is sysmonforlinux, add the repository
if [ "$install_package" = "sysmonforlinux" ]; then
    wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O ./packages/packages-microsoft-prod.deb
    wget -q https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml -O ./packages/sysmonconfig.xml
fi

# Update package lists
sudo apt-get update

# Install apt-rdepends if not already installed
if ! command -v apt-rdepends &> /dev/null; then
    sudo apt-get install -y apt-rdepends
fi

# List all dependencies of the package
dependencies=$(apt-rdepends $install_package | grep -v "^ ")

# Download the package and all its dependencies
for package in $dependencies; do
    sudo apt-get install --download-only -y $package
    cp /var/cache/apt/archives/$package*.deb ./packages/$package.deb
done

# Create an ISO file from the downloaded packages
genisoimage -o ${install_package}.iso packages/

# Clean up
rm -r packages