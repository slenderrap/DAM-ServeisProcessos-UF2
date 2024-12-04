const fs = require('fs').promises
const readline = require('readline').promises
const {Tresor,Casella} = require('./Tresor')

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
        console.log(comanda[comanda.length-1])

        if (comanda.startsWith("destapar")){
            return comanda
        }
        else if (!opcionsComanda.includes(comanda)){
           
            console.log("Comanda desconeguda")
        }
    }

    console.log(`La comanda es: ${comanda}`)
    
    rl.close()
    return comanda
}

async function main() {
    let trampa = false
    //tresor será ! i no tresor _
    //Fem una matriu 8x6 primer indiquem les files i depres les columnes, per ultim indiquem el valor base de totes les caselles
    let opcionsComanda = ["ajuda","help","carregar partida","guardar partida","activar trampa","desactivar trampa","destapar XY","puntuacio"]
    let matriu = Array(6).fill().map(() => Array(8).fill(null));

    var files="abcdef"
    
    for (let i = 0; i<16; i++){
        let columna = Math.floor(Math.random() *8)
        let fila = Math.floor(Math.random() *6)
        if (matriu[fila][columna]===null){
            matriu[fila][columna] = new Tresor(files[fila],columna)
        }else{
            continue
        }
    }
    for (let fila = 0; fila<6; fila++){
        for (let columna = 0; columna<8; columna++){
            if (matriu[fila][columna]===null){
                matriu[fila][columna] = new Casella(files[fila],columna)
            }
        }
    }

    while (true){
    
        await imprimirTablero(matriu,trampa);
        comanda = await opcions(opcionsComanda)
        if (comanda.startsWith("destapar")){
            if (comanda.length==11){
                columna = parseInt(comanda[comanda.length-1])
                console.log(typeof columna)
                if (typeof columna ==="number"){
                    if(0<=columna && columna<=7){
                        console.log(`La columna es ${columna}`)
                        fila = comanda[comanda.length-2]
                        console.log(`La fila es ${fila}`)
                        if (files.includes(fila)){
                            matriu[files.indexOf(fila)][columna].destapar()
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
                    console.log("abrir json")
                    break
                case "guardar partida":
                    console.log("guardar json")
                    break
                case "activar trampa":
                    trampa=true
                    console.log("mostrar tablero x2")
                    break
                case "desactivar trampa":
                    trampa=false
                    console.log("tablero x1")
                    break
                case "puntuacio":
                    console.log("")
                    break
            }
        }    


    
    }
}

main()