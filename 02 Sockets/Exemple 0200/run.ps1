# run.ps1

# Exemple de funcionament: .\run.ps1 Client
# on 'Client' o 'Server' són els paràmetres que indiquen quina classe volem executar

# Set console output to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Change to the directory where the script is located
Set-Location $PSScriptRoot

# Set MAVEN_OPTS environment variable
$env:MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.nio=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED -Dfile.encoding=UTF8"

# Verifica si s'ha passat un argument
if (-not $args[0]) {
    Write-Host "Error: Has de passar un argument: 'Client' o 'Server'."
    exit 1
}

# Assigna el perfil i la classe principal segons l'argument passat
$profile = ""
$mainClass = ""

switch ($args[0]) {
    "Client" {
        $profile = "runClient"
        $mainClass = "com.project.Client"
    }
    "Server" {
        $profile = "runServer"
        $mainClass = "com.project.Server"
    }
    default {
        Write-Host "Error: L'argument ha de ser 'Client' o 'Server'."
        exit 1
    }
}

Write-Host "Setting MAVEN_OPTS to: $env:MAVEN_OPTS"
Write-Host "Executing Maven profile: $profile with Main Class: $mainClass"

# Construcció dels arguments d'execució per a Maven
$execArg = "-Dexec.mainClass=" + $mainClass

# Execució de la comanda Maven
mvn -q clean test-compile exec:java -P$profile $execArg
