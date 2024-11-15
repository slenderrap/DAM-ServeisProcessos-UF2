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

# SSH al servidor per aturar el procés i alliberar el port
ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    cd "\$HOME/nodejs_server"

    echo "Configurant el PATH per a Node.js..."
    export PATH="\$HOME/.npm-global/bin:/usr/local/bin:\$PATH"

    # Intentar aturar el servidor amb Node.js
    echo "Aturant el servidor amb Node.js..."
    if command -v node &>/dev/null; then
        node --run pm2stop || echo "Error en aturar el servidor. Intentant forçar..."
    fi

    pkill -f "node" || echo "No s'ha trobat cap procés de Node.js en execució."

    # Comprovar si el port està alliberat
    echo "Comprovant si el port $SERVER_PORT està alliberat..."
    MAX_RETRIES=10
    RETRIES=0
    while netstat -an | grep -q ":$SERVER_PORT.*LISTEN"; do
        echo "Esperant que el port $SERVER_PORT es desalliberi..."
        sleep 1
        RETRIES=\$((RETRIES + 1))
        if [[ \$RETRIES -ge \$MAX_RETRIES ]]; then
            echo "Error: El port $SERVER_PORT no es desallibera."
            exit 1
        fi
    done

    echo "Port $SERVER_PORT desalliberat."
    exit
EOF

# Finalitzar l'agent SSH
ssh-agent -k

cd proxmox
