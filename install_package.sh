#!/bin/bash

# The path to the local log file
log_file="./error.log"

# Unzip the packages folder
unzip -o ./packages.zip -d ./packages 2>>$log_file

# Install the package
echo "Installing the packages..."
sudo dpkg -i ./packages/*.deb 2>>$log_file

# Check if the dpkg command was successful
if [ $? -ne 0 ]; then
    echo "Failed to install the packages" >>$log_file
else
    echo "Packages installed successfully" >>$log_file
fi

# Remove the packages directory
rm -r ./packages

# Remove the packages.zip file
rm ./packages.zip

# echo log file
cat $log_file