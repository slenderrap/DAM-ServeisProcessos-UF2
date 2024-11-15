# Read variables from config.env
$configFile = "config.env"
Get-Content $configFile | ForEach-Object {
    $line = $_
    if ($line -match "(\S+)\s*=\s*(.+)") {
        $key = $matches[1]
        $value = $matches[2]

        if ($value -like "*HOME*") {
            $value = $value -replace "HOME", "$HOME"
            $value = $value -replace '\$', ''
        }

        $value = $value -replace '/', '\'
        $value = $value -replace '"', ''

        # Set the variable in PowerShell
        Set-Variable -Name $key -Value $value
    }
}

# Get parameters with defaults from config.env
$USER = if ($args.Count -ge 1) { $args[0] } else { $DEFAULT_USER }
$RSA_PATH = if ($args.Count -ge 2) { $args[1] } else { $DEFAULT_RSA_PATH }
$SERVER_PORT = if ($args.Count -ge 3) { $args[2] } else { $DEFAULT_SERVER_PORT }

Write-Host "User: $USER"
Write-Host "Ruta RSA: $RSA_PATH"
Write-Host "Server port: $SERVER_PORT"

$ZIP_NAME = "server-package.zip"

# Define function to ensure we return to proxmox folder on failure
function Exit-Script {
    Write-Host "Returning to proxmox folder..."
    Set-Location proxmox
    exit 1
}

# Change directory to parent
Set-Location .. 

# Check if RSA_PATH exists, exit if not
if (-Not (Test-Path $RSA_PATH)) {
    Write-Host "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    Exit-Script
}

# Remove any existing ZIP_NAME file
if (Test-Path $ZIP_NAME) {
    Remove-Item -Force $ZIP_NAME
}

# Create ZIP archive excluding 'proxmox', 'node_modules', and '.gitignore'
try {
    Get-ChildItem -Path . -Exclude "proxmox", "node_modules", ".gitignore" | Compress-Archive -DestinationPath $ZIP_NAME -Force
} catch {
    Write-Host "Error during compression"
    Exit-Script
}

# Use scp to send the zip file to the server
scp -o HostKeyAlgorithms=+ssh-rsa -i $RSA_PATH -P 20127 $ZIP_NAME "$USER@ieticloudpro.ieti.cat:~/"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error durant l'enviament SCP"
    Exit-Script
}

# Remove local zip file
Remove-Item -Force $ZIP_NAME

# Build the SSH command to execute on the server
$sshCommandTemplate = @'
mkdir -p "\$HOME/nodejs_server"
cd "$HOME/nodejs_server"

# Configure PATH for Node.js
echo "Configurant el PATH per a Node.js..."
export PATH="\$HOME/.npm-global/bin:/usr/local/bin:\$PATH"

# Attempt to stop the server gracefully
echo "Aturant el servidor amb Node.js..."
if command -v node &>/dev/null; then
    node --run pm2stop || echo "Error en aturar el servidor. Intentant forçar..."
fi

pkill -f "node" || echo "No s'ha trobat cap procés de Node.js en execució."

# Wait for the server port to be freed
echo "Comprovant si el port PORT_PLACEHOLDER està alliberat..."
MAX_RETRIES=10
RETRIES=0
while netstat -an | grep -q ":PORT_PLACEHOLDER.*LISTEN"; do
    echo "Esperant que el port PORT_PLACEHOLDER es desalliberi..."
    sleep 1
    RETRIES=$((RETRIES + 1))
    if [ $RETRIES -ge $MAX_RETRIES ]; then
        echo "Error: El port PORT_PLACEHOLDER no es desallibera."
        exit 1
    fi
done
echo "Port PORT_PLACEHOLDER desalliberat."

# Clean the directory except for node_modules
echo "Netejant el directori..."
find . -mindepth 1 -not -name "node_modules" -exec rm -rf {} +

# Extract the new ZIP file and install dependencies
cd ..
unzip ZIP_PLACEHOLDER -d nodejs_server
rm -f ZIP_PLACEHOLDER
cd nodejs_server
echo "Instal·lant dependències..."
if npm install; then
    echo "Dependències instal·lades correctament."
else
    echo "Error durant la instal·lació de dependències."
    exit 1
fi

# Restart the server
echo "Reiniciant el servidor amb Node.js..."
if node --run pm2start; then
    echo "Servidor reiniciat correctament."
else
    echo "Error en reiniciar el servidor."
    exit 1
fi
exit
'@

# Replace placeholders with actual values
$sshCommand = $sshCommandTemplate `
    -replace "ZIP_PLACEHOLDER", $ZIP_NAME `
    -replace "PORT_PLACEHOLDER", $SERVER_PORT

# SSH into the server and execute the commands
ssh -o HostKeyAlgorithms=+ssh-rsa -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" $sshCommand

# Change directory back to proxmox
Set-Location proxmox
