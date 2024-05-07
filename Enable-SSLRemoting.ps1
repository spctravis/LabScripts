# Define the IP address for the certificate
$ipAddress = "10.0.0.1"  # Replace with your IP address

# Create a self-signed certificate
$cert = New-SelfSignedCertificate -DnsName $ipAddress -CertStoreLocation "cert:\LocalMachine\My"

# Get the thumbprint of the certificate
$thumbprint = $cert.Thumbprint

# 1. **Export the Server's Certificate**

# On the server, export the self-signed certificate to a .cer file:

$thumbprint = "YourCertThumbprint"  # Replace with your certificate's thumbprint
$certPath = "cert:\LocalMachine\My\$thumbprint"
$exportPath = "C:\temp\serverCert.cer"  # Replace with your desired export path

$cert = Get-Item $certPath
Export-Certificate -Cert $cert -FilePath $exportPath


# 2. **Import the Server's Certificate on the Client**

# Transfer the .cer file to the client machine (e.g., via network share, USB drive, etc.), and then import it into the Trusted Root Certification Authorities store:

$importPath = "C:\temp\serverCert.cer"  # Replace with the path to the .cer file

Import-Certificate -FilePath $importPath -CertStoreLocation "Cert:\LocalMachine\Root"

# 3. **Create a PowerShell Session Over HTTPS**

$session = New-PSSession -ComputerName "ServerIPAddress" -UseSSL -Credential (Get-Credential)
