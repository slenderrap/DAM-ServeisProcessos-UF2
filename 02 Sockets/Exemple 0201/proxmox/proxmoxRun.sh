#!/bin/bash

source ./config.env

# Obtenir configuració dels paràmetres
USER=${1:-$DEFAULT_USER}
RSA_PATH=${2:-$DEFAULT_RSA_PATH}
SERVER_PORT=${3:-$DEFAULT_SERVER_PORT}

echo "User: $USER"
echo "Ruta RSA: $RSA_PATH"
echo "Server port: $SERVER_PORT"

JAR_NAME="server-package.jar"
JAR_PATH="./target/$JAR_NAME"

cd ..

# Comprovem que els arxius existeixen
if [[ ! -f "$RSA_PATH" ]]; then
    echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    cd proxmox
    exit 1
fi

# Generar '.jar'
rm -f JAR_PATH
./run.sh com.server.Main build

if [[ ! -f "$JAR_PATH" ]]; then
    echo "Error: No s'ha trobat l'arxiu JAR: $JAR_PATH"
    cd proxmox
    exit 1
fi

# Iniciar ssh-agent i carregar la clau RSA
eval "$(ssh-agent -s)"
ssh-add "$RSA_PATH"

# Enviament SCP del JAR al servidor
scp -P 20127 "$JAR_PATH" "$USER@ieticloudpro.ieti.cat:~/"
if [[ $? -ne 0 ]]; then
    echo "Error durant l'enviament SCP"
    cd proxmox
    exit 1
fi

# SSH al servidor per fer executar el JAR
ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    cd "\$HOME/"
    setsid nohup java -jar $JAR_NAME > output.log 2>&1 &
    sleep 1
    exit
EOF

# Finalitzar l'agent SSH
ssh-agent -k

cd proxmox