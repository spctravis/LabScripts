#!/bin/bash

# Check if all required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: ./move_files.sh \"hostname1 hostname2 hostname3\" /path/to/source /path/to/destination"
    echo "The -a option in the rsync command stands for "archive", which means it will recursively copy directories (including empty ones), and it will preserve nearly all file attributes including timestamps, permissions, and ownership information."
    exit 1
fi

# The list of hostnames
hostnames=($1)

# The source directory
source_dir=$2

# The destination directory
destination_dir=$3

# Iterate over the hostnames
for hostname in "${hostnames[@]}"; do
    # Copy the files from the source directory to the destination directory on the remote host
    rsync -avz $source_dir/* $hostname:$destination_dir
done