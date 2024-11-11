# Node.js al Proxmox

Connectar-se al proxmox:

```bash
ssh -i id_rsa -p 20127 nomUsuari@ieticloudpro.ieti.cat
```

Suposant que 'id_rsa' és l'arxiu que té la clau privada d'accés al Proxmox

## Instal·lar Node.js

```python
sudo apt install unzip
sudo apt install npm
sudo npm cache clean -f
sudo npm install -g n
sudo n latest
```

## Carpeta Proxmox

Pujar el servidor:
```bash
cd proxmox
./proxmoxRun.sh
```

Validar que funciona, navegar a [https://nomUsuari.ieti.site/](https://nomUsuari.ieti.site/)

