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

# SSH command template with placeholder for the port
$sshCommandTemplate = @"
cd "\$HOME/nodejs_server"
echo "Aturant el servidor amb PM2..."
if pm2 stop all; then
    echo "Servidor aturat correctament."
else
    echo "Error en aturar el servidor. Intentant forçar..."
    pkill -f "node" || echo "No s'ha trobat cap procés de Node.js en execució."
fi

echo "Comprovant si el port PORT_PLACEHOLDER està alliberat..."
MAX_RETRIES=10
RETRIES=0
while netstat -an | grep -q ":PORT_PLACEHOLDER.*LISTEN"; do
    echo "Esperant que el port PORT_PLACEHOLDER es desalliberi..."
    sleep 1
    RETRIES=\$((RETRIES + 1))
    if [ \$RETRIES -ge \$MAX_RETRIES ]; then
        echo "Error: El port PORT_PLACEHOLDER no es desallibera."
        exit 1
    fi
done
echo "Port PORT_PLACEHOLDER desalliberat."
exit
"@

# Replace the placeholder with the actual server port
$sshCommand = $sshCommandTemplate -replace "PORT_PLACEHOLDER", $SERVER_PORT

# SSH into the server and execute the commands
ssh -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" $sshCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: SSH connection failed or command did not execute successfully."
    Exit-Script
}

# Change directory back to proxmox
Set-Location proxmox
