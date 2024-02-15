#!/bin/bash

# The path to the local log file
log_file="./error.log"

# Echo hostname to log file
echo "Hostname: $(hostname)" >>$log_file

# Unzip the packages folder
unzip -o ./packages.zip -d ./packages 2>>$log_file

# Install the package
echo "Installing the packages..."
cd ./packages
sudo dpkg -i *.deb 2>>$log_file

# Check if the dpkg command was successful
if [ $? -ne 0 ]; then
    echo "Failed to install the packages" >>$log_file
else
    echo "Packages installed successfully" >>$log_file
fi

# run sysmon install with the config file
sudo sysmon -i sysmonconfig.xml

# wait for 5 seconds
sleep 5

# Check if sysmon service is running if not start it, if it won't start, log it
if ! sudo systemctl is-active --quiet sysmon; then
    sudo systemctl start sysmon
    if [ $? -ne 0 ]; then
        echo "Failed to start sysmon service" >>$log_file
    else
        echo "Sysmon service started successfully" >>$log_file
    fi
fi

# Remove the packages directory
rm -r ./packages

# Remove the packages.zip file
rm ./packages.zip

# echo log file
cat $log_file