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

# Assignar variables d'entorn i valors predeterminats
$USER = if ($args.Count -ge 1) { $args[0] } else { $DEFAULT_USER }
$RSA_PATH = if ($args.Count -ge 2) { $args[1] } else { $DEFAULT_RSA_PATH }
$SERVER_PORT = if ($args.Count -ge 3) { $args[2] } else { $DEFAULT_SERVER_PORT }

Write-Host "User: $USER"
Write-Host "Ruta RSA: $RSA_PATH"
Write-Host "Server port: $SERVER_PORT"

$JAR_NAME = "server-package.jar"

Set-Location ..

# Verificar la clau RSA
if (-Not (Test-Path $RSA_PATH)) {
    Write-Host "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    Set-Location proxmox
    exit 1
}

# Script SSH per aturar el procés i alliberar el port
$sshCommandTemplate = @'
cd $HOME
PID=$(ps aux | grep 'java -jar JAR_PLACEHOLDER' | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "Aturant el procés $PID..."
    kill -15 $PID
    for i in {1..10}; do
        if ! ps -p $PID > /dev/null; then
            echo "Procés $PID aturat correctament."
            break
        fi
        echo "Esperant que el procés finalitzi..."
        sleep 1
    done
    if ps -p $PID > /dev/null; then
        echo "Procés $PID encara actiu, forçant aturada..."
        kill -9 $PID
    fi
else
    echo "No s'ha trobat el procés JAR_PLACEHOLDER."
fi

# Comprovar que el port s'hagi alliberat
while netstat -an | grep -q ':PORT_PLACEHOLDER.*LISTEN'; do
    echo "Esperant que el port PORT_PLACEHOLDER es desalliberi..."
    sleep 1
done
echo "Port PORT_PLACEHOLDER desalliberat."
exit
'@

# Substituir placeholders amb els valors actuals
$sshCommand = $sshCommandTemplate `
    -replace "JAR_PLACEHOLDER", $JAR_NAME `
    -replace "PORT_PLACEHOLDER", $SERVER_PORT

# Executar el script SSH
ssh -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" $sshCommand

Set-Location proxmox
