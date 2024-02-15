#!/bin/bash

# Check if all required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 \"hostname1 hostname2 hostname3\" /path/to/local/file.sh password"
    exit 1
fi

# The list of hostnames
hostnames=($1)

# The path to the local .sh file
local_file=$2

# The password
password=$3

# The path to the local log file
log_file="./error.log"

# Warning about insecure method
echo "WARNING: This method of passing the password is insecure and should not be used in production environments."

# Iterate over the hostnames
for hostname in "${hostnames[@]}"; do
    # Copy the local .sh file to the remote host
    echo $password | perl -e 'alarm 10; exec @ARGV' "scp $local_file $hostname:~" 2>>$log_file

    # Check if the scp command was successful
    if [ $? -ne 0 ]; then
        echo "Failed to copy $local_file to $hostname" >>$log_file
        continue
    fi

    # Open a remote connection and run the .sh file
    echo $password | perl -e 'alarm 10; exec @ARGV' "ssh $hostname \"bash ~/$(basename $local_file)\"" 2>>$log_file

    # Check if the ssh command was successful
    if [ $? -ne 0 ]; then
        echo "Failed to run $(basename $local_file) on $hostname" >>$log_file
    fi
done

# echo log file
cat $log_file