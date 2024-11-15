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

# Generar el .zip excloent directoris innecessaris
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

    # Intentar aturar el servidor gracefully
    echo "Aturant el servidor de manera graceful..."
    if pm2 stop all; then
        echo "Servidor aturat correctament."
    else
        echo "Error en aturar el servidor. Intentant forçar..."
        pkill -f "node" || echo "No s'ha trobat cap procés de Node.js en execució."
    fi

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

    # Netejar el directori excepte node_modules
    echo "Netejant el directori del servidor..."
    find . -mindepth 1 -not -name "node_modules" -exec rm -rf {} +

    # Descomprimir el nou paquet i instal·lar dependències
    cd ..
    unzip $ZIP_NAME -d nodejs_server
    rm -f $ZIP_NAME
    cd nodejs_server

    echo "Instal·lant dependències..."
    npm install

    # Reiniciar el servidor amb PM2
    echo "Reiniciant el servidor amb PM2..."
    pm2 start all
    echo "Servidor reiniciat correctament."
    exit
EOF

# Finalitzar l'agent SSH
ssh-agent -k

cd proxmox
