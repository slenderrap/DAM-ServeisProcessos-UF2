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

# SSH into the server to stop the server process
ssh -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" 'cd "$HOME/nodejs_server"; node --run pm2stop; exit'
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: SSH connection failed or command did not execute successfully."
    Exit-Script
}

# Change directory back to proxmox
Set-Location proxmox
