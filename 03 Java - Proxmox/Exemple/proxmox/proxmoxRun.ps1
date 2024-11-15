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

# Assignar els paràmetres
$USER = if ($args.Count -ge 1) { $args[0] } else { $DEFAULT_USER }
$RSA_PATH = if ($args.Count -ge 2) { $args[1] } else { $DEFAULT_RSA_PATH }
$SERVER_PORT = if ($args.Count -ge 3) { $args[2] } else { $DEFAULT_SERVER_PORT }

Write-Host "User: $USER"
Write-Host "Ruta RSA: $RSA_PATH"
Write-Host "Server port: $SERVER_PORT"

$JAR_NAME = "server-package.jar"
$JAR_PATH = ".\target\$JAR_NAME"

Set-Location ..

# Verificar el fitxer de clau privada
if (-Not (Test-Path $RSA_PATH)) {
    Write-Host "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    Set-Location proxmox
    exit 1
}

# Construir el JAR
if (Test-Path $JAR_PATH) {
    Remove-Item -Force $JAR_PATH
}
.\run.ps1 com.server.Main build

# Verificar el JAR generat
if (-Not (Test-Path $JAR_PATH)) {
    Write-Host "Error: No s'ha trobat l'arxiu JAR: $JAR_PATH"
    Set-Location proxmox
    exit 1
}

# Enviar el JAR al servidor
Write-Host "Enviant $JAR_PATH al servidor..."
scp -i $RSA_PATH -P 20127 $JAR_PATH "$USER@ieticloudpro.ieti.cat:~/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error durant l'enviament SCP"
    Set-Location proxmox
    exit 1
}

# Substituir placeholders al script SSH
$sshCommandTemplate = @'
cd $HOME
PID=$(ps aux | grep 'java -jar JAR_PLACEHOLDER' | grep -v 'grep' | awk '{print $2}')
if [ -n "$PID" ]; then
    kill -15 $PID
    echo "Senyal SIGTERM enviat al procés $PID."
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

while netstat -an | grep -q ':PORT_PLACEHOLDER.*LISTEN'; do
    echo "Esperant que el port PORT_PLACEHOLDER es desalliberi..."
    sleep 1
done

setsid nohup java -jar JAR_PLACEHOLDER > output.log 2>&1 &
sleep 1
PID=$(ps aux | grep 'java -jar JAR_PLACEHOLDER' | grep -v 'grep' | awk '{print $2}')
if [ -n "$PID" ]; then
    echo "Nou procés JAR_PLACEHOLDER amb PID $PID arrencat correctament."
else
    echo "Error: No s'ha pogut arrencar el nou procés JAR_PLACEHOLDER."
    exit 1
fi
exit
'@

# Substituir placeholders per valors reals
$sshCommand = $sshCommandTemplate `
    -replace "JAR_PLACEHOLDER", $JAR_NAME `
    -replace "PORT_PLACEHOLDER", $SERVER_PORT

# Executar el comandament SSH
ssh -i $RSA_PATH -t -p 20127 "$USER@ieticloudpro.ieti.cat" $sshCommand

Set-Location proxmox
