<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

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

Redireccionar el port 80 i pujar el servidor:
```bash
cd proxmox
./proxmoxRedirect80.sh
./proxmoxRun.sh
```

Validar que funciona, navegar a [https://nomUsuari.ieti.site/](https://nomUsuari.ieti.site/)

Aturar el servidor i desfer la redirecció del port 80:
```bash
cd proxmox
./proxmoxStop.sh
./proxmoxRedirectUndo.sh
```