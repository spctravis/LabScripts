#!/bin/bash

# List of DNS names
ips=("example1.com" "example2.com" "example3.com")

# Read the CSV file and pick 20 random lines
mapfile -t users < <(shuf -n 20 usersandpasswords.csv)

# Create or clear the linuxusers.txt file
> linuxusers.txt

# Loop over each DNS name
for ip in "${ips[@]}"; do
    # Loop over each user-password pair
    for userpass in "${users[@]}"; do
        IFS=',' read -r -a array <<< "$userpass"
        user="${array[0]}"
        pass="${array[1]}"

        # Write the user and password to the linuxusers.txt file
        echo "$user,$pass" >> linuxusers.txt

        # Use SSH to add the user to the remote machine
        ssh root@$ip "
            useradd $user
            echo $user:$pass | chpasswd
        "
    done
done