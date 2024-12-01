const fs = require('fs').promises
const readline = require('readline').promises

async function imprimirTablero(matriu){
    var fila = ""
    for (let i=-1;i<8;i++){
        if (i!==-1){
            fila +=i;
        }else{
            fila =" ";
        }
    }
    
    console.log(fila)
    let start = 'A'.charCodeAt(0);
    let end = 'F'.charCodeAt(0)+1;
    for (let i=start;i<end;i++){
        fila = String.fromCharCode(i);
        let n_fila = i-start;
        for (let j=0;j<8;j++){
            fila += matriu[n_fila][j];
        }
        console.log(fila)
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
            if (comanda.length==11){
                columna = parseInt(comanda[comanda.length-1])
                console.log(typeof columna)
                if (!typeof columna !=="number"){
                    console.error("La columna debe ser un numero")
                }else if(0>=columna<=7){
                    console.log(columna)
                }
                fila = console.log(comanda[comanda.length-2])
            }
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
    let opcionsComanda = ["ajuda","help","carregar partida","guardar partida","activar trampa","desactivar trampa","destapar","puntuacio"]
    let matriu = Array(6).fill().map(() => Array(8).fill("."));
    while (true){
    
        await imprimirTablero(matriu,trampa);
        comanda = await opcions(opcionsComanda)
        if (comanda.startsWith("destapar")){

        }else{
            switch (comanda){
                case "ajuda":
                case "help":
                    console.log("imprimir totes les comandes")
                    break
                case "carregar partida":
                    console.log("abrir json")
                    break
                case "guardar partida":
                    console.log("guardar json")
                    break
                case "activar trampa":
                        console.log("mostrar tablero x2")
                        break
                case "desactivar trampa":
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