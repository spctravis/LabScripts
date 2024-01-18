fi

# The package to be installed
install_me=$1

# Update package lists
sudo apt-get update

# If the package to be installed is Visual Studio Code, add the repository
if [ "$install_me" = "code" ]; then
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt-get update
fi

# Install apt-rdepends if not already installed
if ! command -v apt-rdepends &> /dev/null; then
    sudo apt-get install -y apt-rdepends
fi

# List all dependencies of the package
dependencies=$(apt-rdepends $install_me | grep -v "^ ")

# Create a directory to store the downloaded packages
mkdir -p packages

# Download the package and all its dependencies
for package in $dependencies; do
    sudo apt-get install --download-only -y $package
    cp /var/cache/apt/archives/$package*.deb packages/
done

# Create an ISO file from the downloaded packages
genisoimage -o ${install_me}.iso packages/

# Clean up
rm -r packages