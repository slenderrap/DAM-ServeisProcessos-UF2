const express = require('express')
const multer = require('multer')
const app = express()
const port = 3000

//serveix 
app.use(express.static('public/images'))

//fem la comanda get 
app.get('/',(req,res)=>{
    res.send('Hello world desde get')
});

//per fer servir la comanda post
app.post('/api', async (req, res) => {
    // Obtenir valors del cos de la petició
    const { param1, param2 } = req.body

    res.json({
        message: 'Dades rebudes',
        param1: param1,
        param2: param2
    })
})


//iniciar servidor, ho fiquem en una variable per poder tancar-ho correctament
const httpServer = app.listen(port,()=>{
    console.log(`Servior iniciat en http://localhost:${port}`)
})

//tancar servidor
//SIGTERM equival a ctrl + C y SIGINT a fer un kill del process
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

function shutDown() {
    // Executar aquí el codi previ al tancament de servidor
    console.log('Received kill signal, shutting down gracefully');
    httpServer.close()
    process.exit(0);
}
