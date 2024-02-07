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
    wget -q https://raw.githubusercontent.com/microsoft/MSTIC-Sysmon/main/linux/configs/main.xml -O ./packages/sysmonconfig.xml
    sudo dpkg -i ./packages/packages-microsoft-prod.deb
fi

# Update package lists
sudo apt-get update

# Install apt-rdepends if not already installed
if ! command -v apt-rdepends &> /dev/null; then
    sudo apt-get install -y apt-rdepends
fi

# List all dependencies of the package
dependencies=$(apt-rdepends $install_package | awk '!/^ / {print $0} /^  Depends: / {print $2}' )
echo dependencies

# Make the backup directory
mkdir -p /var/cache/apt/archives/backup/

# Move the existing packages to a backup directory
mv /var/cache/apt/archives/*.deb /var/cache/apt/archives/backup/

# Download the package and all its dependencies
for package in $dependencies; do
    sudo apt-get install --download-only -y $package 
done

# Move the downloaded packages to the packages directory
mv /var/cache/apt/archives/*.deb ./packages/

# move the backup packages back to the archives directory
mv /var/cache/apt/archives/backup/* /var/cache/apt/archives/

# Remove the backup directory
rm -r /var/cache/apt/archives/backup/

# Install the package
echo "This is the command to install the packages:"
echo "sudo dpkg -i ./packages/*.deb"