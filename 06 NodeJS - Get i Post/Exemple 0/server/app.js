const express = require('express')
const app = express()
const port = 3000

// Continguts estàtics (carpeta public)
app.use(express.static('public'))

// Configurar direcció ‘/’ 
app.get('/', async (req, res) => {
    res.send(`Hello World /`)
})

// Configurar direcció ‘/api’ 
app.get('/api', async (req, res) => {
    res.send(`Hello World get`)
})

// Configurar direcció ‘/api’ 

app.post('/api', async (req, res) => {
    res.send({message: 'Dades rebudes'})
})



// Activar el servidor
const httpServer = app.listen(port, appListen)
function appListen () {
    console.log(`Example app listening on: http://0.0.0.0:${port}`)
}

// Aturar el servidor correctament 
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
    // Executar aquí el codi previ al tancament de servidor
    
    console.log('Received kill signal, shutting down gracefully');
    httpServer.close()
    process.exit(0);
}
