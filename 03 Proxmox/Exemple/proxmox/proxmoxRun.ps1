# Llegir les línies de l'arxiu config.env
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

        # Configurar la variable en PowerShell
        Set-Variable -Name $key -Value $value
    }
}

$USER = if ($args.Count -ge 1) { $args[0] } else { $DEFAULT_USER }
$RSA_PATH = if ($args.Count -ge 2) { $args[1] } else { $DEFAULT_RSA_PATH }
$SERVER_PORT = if ($args.Count -ge 3) { $args[2] } else { $DEFAULT_SERVER_PORT }

Write-Host "User: $USER"
Write-Host "Ruta RSA: $RSA_PATH"
Write-Host "Server port: $SERVER_PORT"

$JAR_NAME="server-package.jar"
$JAR_PATH = ".\target\$JAR_NAME"

Set-Location ..

if (-Not (Test-Path $RSA_PATH)) {
    Write-Host "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    Set-Location proxmox
    exit 1
}

if (Test-Path $JAR_PATH) {
    Remove-Item -Force $JAR_PATH
}
.\run.ps1 com.server.Main build

if (-Not (Test-Path $JAR_PATH)) {
    Write-Host "Error: No s'ha trobat l'arxiu JAR: $JAR_PATH"
    Set-Location proxmox
    exit 1
}

scp -i $RSA_PATH -P 20127 $JAR_PATH "$USER@ieticloudpro.ieti.cat:~/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error durant l'enviament SCP"
    Set-Location proxmox
    exit 1
}

$sshCommand = @"
cd $HOME
setsid nohup java -jar $($JAR_NAME) > output.log 2>&1 &
sleep 1
exit
"@ -replace "`r", ""
ssh -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" $sshCommand

Set-Location proxmox
