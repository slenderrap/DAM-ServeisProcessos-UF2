#!/bin/bash

# Function for cleanup
cleanup() {
    local exit_code=$?
    echo "Performing cleanup..."
    [[ -n "$TEMP_KEY" ]] && rm -f "$TEMP_KEY"
    [[ -n "$JAR_PATH" ]] && rm -f "$JAR_PATH"
    ssh-agent -k 2>/dev/null
    cd "$ORIGINAL_DIR" 2>/dev/null
    exit $exit_code
}

# Set up trap for cleanup on script exit
trap cleanup EXIT

# Store original directory
ORIGINAL_DIR=$(pwd)

source ./config.env

USER=${1:-$DEFAULT_USER}
RSA_PATH=${2:-"$DEFAULT_RSA_PATH"}
SERVER_PORT=${3:-$DEFAULT_SERVER_PORT}
RSA_PATH="${RSA_PATH%$'\r'}"

echo "User: $USER"
echo "Ruta RSA: $RSA_PATH"
echo "Server port: $SERVER_PORT"

JAR_NAME="server-package.jar"
JAR_PATH="./target/$JAR_NAME"

cd ..

if [[ ! -f "$RSA_PATH" ]]; then
    echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
    exit 1
fi

# Create temporary key with secure permissions
TEMP_KEY=$(mktemp)
cp "${RSA_PATH}" "$TEMP_KEY"
chmod 600 "$TEMP_KEY"

echo "Generant el fitxer JAR..."
rm -f "$JAR_PATH"
./run.sh com.server.Main build

if [[ ! -f "$JAR_PATH" ]]; then
    echo "Error: No s'ha trobat l'arxiu JAR: $JAR_PATH"
    exit 1
fi

eval "$(ssh-agent -s)"
ssh-add "$TEMP_KEY"

echo "Enviant $JAR_PATH al servidor..."
scp -P 20127 "$JAR_PATH" "$USER@ieticloudpro.ieti.cat:~/"
if [[ $? -ne 0 ]]; then
    echo "Error durant l'enviament SCP"
    exit 1
fi

ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    cd "\$HOME/"

    PID=\$(ps aux | grep 'java -jar $JAR_NAME' | grep -v 'grep' | awk '{print \$2}')
    if [ -n "\$PID" ]; then
      kill -15 \$PID
      echo "Senyal SIGTERM enviat al procés \$PID."
      for i in {1..10}; do
        if ! ps -p \$PID > /dev/null; then
          echo "Procés \$PID aturat correctament."
          break
        fi
        echo "Esperant que el procés finalitzi..."
        sleep 1
      done
      if ps -p \$PID > /dev/null; then
        echo "Procés \$PID encara actiu, forçant aturada..."
        kill -9 \$PID
      fi
    else
      echo "No s'ha trobat el procés $JAR_NAME."
    fi

    MAX_RETRIES=10
    RETRIES=0
    while netstat -an | grep -q ':$SERVER_PORT.*LISTEN'; do
      echo "Esperant que el port $SERVER_PORT es desalliberi..."
      sleep 1
      RETRIES=\$((RETRIES + 1))
      if [ \$RETRIES -ge \$MAX_RETRIES ]; then
        echo "Error: El port $SERVER_PORT no es desallibera després de \$MAX_RETRIES segons."
        exit 1
      fi
    done

    setsid nohup java -jar $JAR_NAME > output.log 2>&1 &
    sleep 1
    PID=\$(ps aux | grep 'java -jar $JAR_NAME' | grep -v 'grep' | awk '{print \$2}')
    if [ -n "\$PID" ]; then
      echo "Nou procés $JAR_NAME amb PID \$PID arrencat correctament."
    else
      echo "Error: No s'ha pogut arrencar el nou procés $JAR_NAME."
      exit 1
    fi
EOF

