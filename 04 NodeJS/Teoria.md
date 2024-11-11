# Node.js

**[Node.js](https://nodejs.org/en)** és un entorn basat en JavaScript que permet  crear programes de xarxa altament escalables, com per exemple servidors web.

**[Express](https://expressjs.com/)** és un framework que permet crear aplicaions web i APIs sobre **Node.js**

<center><img src="./assets/logo-nodejs.png" style="max-width: 90%; max-height: 200px;" alt="">
<br/></center>
<br/>

## Instal·lació

Per instral·lar Node.js amb [gestors de paquets](https://nodejs.org/en/download/package-manager):

A Linux:
```bash
sudo apt install npm
sudo npm cache clean -f
sudo npm install -g n
sudo n latest
```

A MacOX:
```bash
sudo brew install node
sudo npm cache clean -f
sudo npm install -g n
sudo n latest
```
A Windows:
```bash
winget install Schniz.fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
fnm use --install-if-missing 22
fnm install latest
fnm use latest
```

## Nou projecte

Per crear un nou projecte:
```bash
mkdir exemple
cd exemple
npm init -y
```

Un cop creat el projecte apareix l'arxiu **"package.json"** que defineix la configruació del projecte.

Per afegir llibreries al projecte:
```bash
npm install express
npm install pm2
```

- **Express** és el framework que simplifica crear APIs amb Node.js
- **[PM2](https://pm2.keymetrics.io/)** permet vigilar el funcionament del servidor en entorns de producció.

# Crear el servidor
```bash
mkdir server
touch ./server/app.js
```

A l'arxiu **"./server/app.js"** posar-hi:
```javascript
const express = require('express')
const app = express()
const port = 3000

// Configurar direcció ‘/’ 
app.get('/', getHello)
    async function getHello (req, res) {
    res.send(`Hello World`)
}

// Activar el servidor
const httpServer = app.listen(port, appListen)
function appListen () {
    console.log(`Example app listening on: http://localhost:${port}`)
}

// Aturar el servidor correctament
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
    console.log('Received kill signal, shutting down gracefully');
    httpServer.close()
    process.exit(0);
}
```

A l'arxiu **"./package.json"** posar l'apartat **scripts** així:
```json
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "node --watch --watch-path ./server ./server/app.js",
    "pm2start": "pm2 start ./server/app.js",
    "pm2list": "pm2 list",
    "pm2stop": "pm2 delete app"
  },
```
**Desenvolupament**:

Quan estem desenvolupant, es fa anar el servidor amb:
```bash
node --run dev
```

**Nota**: Amb la configuració de *package.json* i el mode *dev* quan es fan canvis als arxius de la carpeta *./server* el servidor es reinicia automàticament.

**Producció (Proxmox)**:

A producció (Proxmox) el servidor funcionarà amb:
```bash
node --run pm2start
```

A producció (Proxmox) tindrem comandes per llistar o aturar el servidor:
```bash
node --run pm2list
node --run pm2stop
```

**Nota**: Amb la configuració de *package.json* i la llibreria *pm2*, quan el servidor s'atura o es penja, es renicia automàticament.

## Validar el servidor local (cmd)

Amb el servidor funcionant, per comprovar que s'hi poden fer consultes:
```bash
curl http://0.0.0.0:3000
```

Ha de mostrar: **"Hello World"**, que és la resposta a la única URL configurada *"/"*

## Validar el servidor local (navegador)

Amb el servidor funcionant, per comprovar que s'hi poden fer consultes. 

Anar amb el navegador a [http://0.0.0.0:3000](http://0.0.0.0:3000)

S'ha de veure una pàgina web amb **"Hello World"**

Anar amb el navegador a [http://localhost:3000/web.html](http://localhost:3000/web.html)

S'ha de veure una pàgina web amb
**"Hello Web HTML"**