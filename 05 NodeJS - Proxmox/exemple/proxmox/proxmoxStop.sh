#!/bin/bash

source ./config.env

# Obtenir configuració dels paràmetres
USER=${1:-$DEFAULT_USER}
RSA_PATH=${2:-$DEFAULT_RSA_PATH}
SERVER_PORT=${3:-$DEFAULT_SERVER_PORT}

echo "User: $USER"
echo "Ruta RSA: $RSA_PATH"
echo "Server port: $SERVER_PORT"

cd ..

# Comprovem que els arxius existeixen
if [[ ! -f "$RSA_PATH" ]]; then
  echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
  cd proxmox
  exit 1
fi

# Iniciar ssh-agent i carregar la clau RSA
eval "$(ssh-agent -s)"
ssh-add "$RSA_PATH"

# SSH al servidor per trobar i matar el procés del servidor
ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    cd "\$HOME/nodejs_server"
    node --run pm2stop
    exit
EOF

# Finalitzar l'agent SSH
ssh-agent -k

cd proxmox