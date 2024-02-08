#!/bin/bash

# The path to the local log file
log_file="./error.log"

# Echo hostname to log file
echo "Hostname: $(hostname)" >>$log_file

# Install the Elastic Agent
echo "Installing the Elastic Agent..."
sudo ./so-elastic-agent_linux_amd64 2>>$log_file

# Check if the install command was successful
if [ $? -ne 0 ]; then
    echo "Failed to install the Elastic Agent" >>$log_file
else
    echo "Elastic Agent installed successfully" >>$log_file
fi

# Check if Elastic Agent service is running if not start it, if it won't start, log it
if ! sudo systemctl is-active --quiet elastic-agent; then
    sudo systemctl start elastic-agent
    if [ $? -ne 0 ]; then
        echo "Failed to start Elastic Agent service" >>$log_file
    else
        echo "Elastic Agent service started successfully" >>$log_file
    fi
fi