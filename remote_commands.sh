#!/bin/bash

# Check if all required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 \"hostname1 hostname2 hostname3\" /path/to/remote/file.sh password"
    exit 1
fi

# The list of hostnames
hostnames=($1)

# The path to the remote .sh file
remote_file=$2

# The password
password=$3

# The path to the remote log file
log_file="./error.log"

# Iterate over the hostnames
for hostname in "${hostnames[@]}"; do
    # Copy the remote .sh file to the remote host
    sshpass -p $password scp $remote_file $hostname:~/Documents 2>>$log_fileq
    # Use sshpass to echo the password to file call password.txt
    sshpass -p $password ssh $hostname - "echo $password > ~/Documents/password.txt" 2>>$log_file
    # Open a remote connection and run the .sh file
    sshpass -p $password ssh $hostname -t "sudo -S < ~/Documents/password.txt bash -s ~/Documents/$(basename $remote_file)" 2>>$log_file
    # remove the password file
    sshpass -p $password ssh $hostname -t "rm ~/Documents/password.txt" 2>>$log_file
    # Check if the ssh command was successful
    if [ $? -ne 0 ]; then
        echo "Failed to run $(basename $remote_file) on $hostname" >>$log_file
    fi
done

# write host log file
cat $log_file