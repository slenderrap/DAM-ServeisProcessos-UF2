const fs = require('fs').promises
const readline = require('readline').promises
const { error } = require('console');
const {Tresor,Casella} = require('./Tresor');
const { publicDecrypt, randomInt } = require('crypto');
const { json } = require('stream/consumers');

async function imprimirTablero(matriu,trampa){
    var fila = ""
    for (let i=-1;i<8;i++){
        if (i!==-1){
            fila +=i;
        }else{
            fila =" ";
        }
    }
    if (!trampa){
        console.log(fila)
        let start = 'A'.charCodeAt(0);
        let end = 'F'.charCodeAt(0)+1;
        for (let i=start;i<end;i++){
            fila = String.fromCharCode(i);
            let n_fila = i-start;
            for (let j=0;j<8;j++){
                fila += matriu[n_fila][j].toString();
            }
            console.log(fila)
        }
    }
    else{
        console.log(fila +"\t"+ fila)
        let start = 'A'.charCodeAt(0);
        let end = 'F'.charCodeAt(0)+1;
        for (let i=start;i<end;i++){
            fila = String.fromCharCode(i);
            let n_fila = i-start;
            for (let j=0;j<8;j++){
                fila += matriu[n_fila][j].toString();
                matriu[n_fila][j].setTrampa()
            }
            fila +="\t"+String.fromCharCode(i);
            for (let j=0;j<8;j++){
                fila += matriu[n_fila][j].toString();
                matriu[n_fila][j].setTrampa()
            }
            console.log(fila)
        }
    

    }
}
async function opcions(opcionsComanda) {
    
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    })
    let comanda = ""
    while (!opcionsComanda.includes(comanda)){
        comanda = (await rl.question("Escriu una comanda: ")).toLowerCase()
        if (comanda.startsWith("destapar")){
            rl.close()
            return comanda
        }
        else if (!opcionsComanda.includes(comanda)){           
            console.log("Comanda desconeguda")
        }
    }

    
    rl.close()
    return comanda
}

async function guardarPartida(matriu, tirada,lletres){
    //volem guardar les tirades que hem fet, caselles descobertes i la posicio i estat dels tresors
    const partida={
        "tirades": tirada, "tresors":[], "caselles":[]
    }
    for (var fila=0;fila<lletres.length;fila++){
        for (var columna=0;columna<matriu[fila].length;columna++){
            if (matriu[fila][columna] instanceof Tresor){
                partida.tresors.push({
                    "posicioX":lletres[fila],
                    "posicioY":columna,
                    "estat":matriu[fila][columna].descoberta
                })
            }else if(matriu[fila][columna].descoberta){
                partida.caselles.push({
                    "posicioX":lletres[fila],
                    "posicioY":columna
                })
            }
        }
    }
    try{
        const jsonData = JSON.stringify(partida,null,2)
        await fs.writeFile('partida.json',jsonData,'utf-8')
        console.log("La partida s'ha guardat correctament")
    }catch(error){
        console.error("S'ha produit un error al guardar la partida: ",error)
    }
}

async function carregarPartida(files) {
    let matriu = Array(6).fill().map(() => Array(8).fill(null));
    console.log("Llegint dades")
    const jsonData= await fs.readFile("partida.json","utf-8")
    const partida = JSON.parse(jsonData)
    tirada = partida.tirades
    tresorsTrobats=0

    console.log("Introduint tresors")
    for(const tresor of partida.tresors){
        matriu[files.indexOf(tresor.posicioX)][tresor.posicioY] = new Tresor(tresor.posicioX,tresor.posicioY,tresor.estat)
        if (tresor.estat){
            tresorsTrobats++
        }
        
    };
    console.log("tresors introduits")

    console.log("introduint caselles obertes")
    for(const casella of partida.caselles){
        matriu[files.indexOf(casella.posicioX)][casella.posicioY] = new Casella(casella.posicioX,casella.posicioY,true)
    }
    console.log("caselles obertes introduides")

    console.log("Introduint caselles sense obrir")
    for (var fila=0;fila<files.length;fila++){
        for (var columna=0;columna<8;columna++){
            if (matriu[fila][columna]===null){
                matriu[fila][columna] = new Casella(files[fila],columna)
            }
        }
    }
    console.log("Caselles tancades introduides")

    puntuacio=tresorsTrobats/16
    console.log("dades llegides")
    

    console.log("Carregant partida...")
    return [matriu,tirada,tresorsTrobats,puntuacio]
}

async function tresorProper(matriu,fila,columna) {
    tresorsPropers=0
    //farem un try catch per a que si es surt del es dimensions no peti el programa
    for (var i=-1;i<2;i++){
        for (var j=-1;j<2 ;j++){
            try {
                
                if (matriu[fila+i][columna+j] instanceof Tresor){
                    tresorsPropers++
                }
            } catch (error) {
                continue
            }

        }
    }
    console.log(`Tens ${tresorsPropers} tresors propers.`)

}

async function main() {
    let trampa = false
    //tresor será ! i no tresor _
    //Fem una matriu 8x6 primer indiquem les files i depres les columnes, per ultim indiquem el valor base de totes les caselles
    //16 tresors 32 tirades puntuacio Z(tresors trobats) /32*
    let opcionsComanda = ["ajuda","help","carregar partida","guardar partida","activar trampa","desactivar trampa","destapar XY","puntuacio","exit"]
    let matriu = Array(6).fill().map(() => Array(8).fill(null));

    var files="abcdef"
    
    var tresors=0
    while (tresors<16){
        let columna = Math.floor(Math.random() *8)
        let fila = Math.floor(Math.random() *6)
        if (matriu[fila][columna]===null){
            matriu[fila][columna] = new Tresor(files[fila],columna)
            tresors++
            //console.log(`nº tresor = ${tresors}, posicio x: ${fila}, posicio y: ${columna}`)
        }
    }
    for (let fila = 0; fila<6; fila++){
        for (let columna = 0; columna<8; columna++){
            if (matriu[fila][columna]===null){
                matriu[fila][columna] = new Casella(files[fila],columna)
            }
        }
    }
    victoria=false
    comanda=""
    tirada =0;
    tresorsTrobats =0;
    puntuacio=0;
    while (comanda!=="exit" && tirada!==32 && tresorsTrobats!=16){
    
        await imprimirTablero(matriu,trampa);
        comanda = await opcions(opcionsComanda)
        if (comanda.startsWith("destapar")){
            if (comanda.length===11){
                columna = parseInt(comanda[comanda.length-1])
                if (typeof columna ==="number"){
                    if(0<=columna && columna<=7){
                        fila = comanda[comanda.length-2]
                        if (files.includes(fila)){
                            matriu[files.indexOf(fila)][columna].destapar()
                            if (matriu[files.indexOf(fila)][columna].toString()==="_"){
                                tirada++
                                //tresor mes proper
                                tresorProper(matriu,files.indexOf(fila),columna)

                            }else{
                                tresorsTrobats++
                                puntuacio = tresorsTrobats/16
                                if (tresorsTrobats===16){
                                    victoria=true
                                }
                            }
                        }else{
                           console.log("La fila ha de ser entre A i F")
                        }
                    }else{
                        console.log("La columna ha de ser entre el 0 i el 7")
                    }
                }else {
                    console.error("La columna ha de ser un numero")
                    
                }
                
            }
        }else{
            switch (comanda){
                case "ajuda":
                case "help":
                    console.log("\n"+"*".repeat(20))  
                    for (let opcioComanda of opcionsComanda){
                        console.log(opcioComanda)
                    }
                    console.log("*".repeat(20)+"\n")  
                    break
                case "carregar partida":
                    const [matriu2,tirada2,tresorsTrobats2,puntuacio2]=await carregarPartida(files)
                    matriu=matriu2
                    tirada=tirada2
                    tresorsTrobats=tresorsTrobats2
                    puntuacio=puntuacio2 
                    break
                case "guardar partida":
                    
                    console.log("Guardant partida...")
                    await guardarPartida(matriu,tirada,files)
                    break
                case "activar trampa":
                    trampa=true
                    break
                case "desactivar trampa":
                    trampa=false                   
                    break
                case "puntuacio":
                    console.log(`La teva puntuacio actual es: ${tresorsTrobats}/16 = ${puntuacio}\nEt queden ${32-tirada} tirades restants`)
                    break
            }
        }    
        console.log("\n")


    
    }
    if (victoria){
        if (tirada===0){
            console.log(`Felicitats, has guanyat amb cap tirada fallada!`)    
        }else{

        }
        console.log(`Felicitats, has guanyat amb nomes ${tirada} tirades fallades!`)
    }else{
        console.log(`Quina llastima, has perdut! La teva puntuacio era de ${tresorsTrobats}/16 = ${puntuacio}`)
    }
    
}

main()
    .then(()=>{
        console.log("Fi del programa")
    })
    .catch((error)=>{
        console.log("Ha ocurrido un error: ",error)
    })
