#!/bin/bash

source ./config.env

# Obtenir configuració dels paràmetres
USER=${1:-$DEFAULT_USER}
RSA_PATH=${2:-$DEFAULT_RSA_PATH}
SERVER_PORT=${3:-$DEFAULT_SERVER_PORT}

echo "User: $USER"
echo "Ruta RSA: $RSA_PATH"
echo "Server port: $SERVER_PORT"

ZIP_NAME="server-package.zip"

cd ..

# Comprovem que els arxius existeixen
if [[ ! -f "$RSA_PATH" ]]; then
    echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    cd proxmox
    exit 1
fi

# Generar '.jar'
rm -f "$ZIP_NAME"
zip -r "$ZIP_NAME" . -x "proxmox/*" "node_modules/*" ".gitignore"

# Iniciar ssh-agent i carregar la clau RSA
eval "$(ssh-agent -s)"
ssh-add "$RSA_PATH"

# Enviament SCP del .zip al servidor
scp -P 20127 "$ZIP_NAME" "$USER@ieticloudpro.ieti.cat:~/"
if [[ $? -ne 0 ]]; then
    echo "Error durant l'enviament SCP"
    cd proxmox
    exit 1
fi

rm -f "$ZIP_NAME"

# SSH al servidor per aturar l'antic procés i executar el nou
ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    cd "\$HOME/nodejs_server"
    node --run pm2stop
    find . -mindepth 1 -path "./node_modules" -prune -o -exec rm -rf {} +
    cd ..
    unzip $ZIP_NAME -d nodejs_server
    rm -f $ZIP_NAME
    cd nodejs_server
    npm install
    node --run pm2start
    exit
EOF

# Finalitzar l'agent SSH
ssh-agent -k

cd proxmox