#!/bin/bash

DEFAULT_USER="nomUsuari"
DEFAULT_RSA_PATH="$HOME/Desktop/Proxmox IETI/id_rsa"
DEFAULT_SERVER_PORT="3000"

USER="${1:-$DEFAULT_USER}"
RSA_PATH=${2:-$DEFAULT_RSA_PATH}

# Demanar la contrasenya remota
read -s -p "Introdueix la contrasenya de sudo per al servidor remot: " SUDO_PASSWORD
echo ""

if [[ ! -f "$RSA_PATH" ]]; then
  echo "Error: No s'ha trobat el fitxer de clau privada: $RSA_PATH"
  exit 1
fi

eval "$(ssh-agent -s)"
ssh-add "$RSA_PATH"

# SSH al servidor i executar la comanda amb sudo, passant la contrasenya
ssh -t -p 20127 "$USER@ieticloudpro.ieti.cat" << EOF
    echo "$SUDO_PASSWORD" | sudo -S iptables-save -t nat | grep -q -- "--dport 80" || echo "$SUDO_PASSWORD" | sudo -S iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $DEFAULT_SERVER_PORT
EOF

ssh-agent -k

