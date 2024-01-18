import os
import subprocess
import urllib.request

# Define the URL of the VS Code .deb package
url = "https://go.microsoft.com/fwlink/?LinkID=760868"

# Define the output file path
output = "VSCode.deb"

# Download the file
urllib.request.urlretrieve(url, output)

# Get the list of dependencies for the .deb package
dependencies = subprocess.check_output(['dpkg', '-I', output, 'Depends']).decode().split('\n')[1].split(',')

# Download each dependency
for dependency in dependencies:
    dependency = dependency.strip().split(' ')[0]
    os.system(f'apt-get download {dependency}')

# Create an ISO file from the .deb package and its dependencies
os.system('genisoimage -o VSCode.iso .')