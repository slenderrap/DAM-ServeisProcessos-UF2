#!/bin/bash

source ./config.env

USER=${1:-$DEFAULT_USER}
RSA_PATH=${2:-"$DEFAULT_RSA_PATH"}
RSA_PATH="${RSA_PATH%$'\r'}"  

echo "User: $USER"
echo "Ruta RSA: $RSA_PATH"

if [[ ! -f "${RSA_PATH}" ]]; then  
  echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
  exit 1
fi

# Use /tmp directory and create a unique filename
TEMP_KEY="/tmp/private_rsa_$$"  
cp "${RSA_PATH}" "$TEMP_KEY"
chmod 600 "$TEMP_KEY"

# Establish SSH connection
ssh -i "$TEMP_KEY" -p 20127 "$USER@ieticloudpro.ieti.cat"  

# Clean up
rm "$TEMP_KEY"