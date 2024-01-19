#!/bash/bin

# The package to be installed
install_package=$1

# Update package lists
sudo apt-get update

# If the package to be installed is Visual Studio Code, add the repository
if [ "$install_package" = "code" ]; then
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt-get update
fi

# If the package to be installed is sysmonforlinux, add the repository
if [ "$install_package" = "sysmonforlinux" ]; then
    wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    wget -q https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml -O sysmonconfig.xml
fi


# Install apt-rdepends if not already installed
if ! command -v apt-rdepends &> /dev/null; then
    sudo apt-get install -y apt-rdepends
fi

# List all dependencies of the package
dependencies=$(apt-rdepends $install_package | grep -v "^ ")

# Create a directory to store the downloaded packages
mkdir -p packages

# Download the package and all its dependencies
for package in $dependencies; do
    sudo apt-get install --download-only -y $package
    cp /var/cache/apt/archives/$package*.deb packages/
done

# If sysmonconfig.xml was downloaded, move it to the packages directory
if [ "$install_package" = "sysmonforlinux" ] && [ -f sysmonconfig.xml ]; then
    mv sysmonconfig.xml packages/
fi

# Create an ISO file from the downloaded packages
genisoimage -o ${install_package}.iso packages/

# Clean up
rm -r packages