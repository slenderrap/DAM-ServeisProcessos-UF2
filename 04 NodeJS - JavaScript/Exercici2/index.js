const fs = require('fs').promises
const readline = require('readline').promises

//Fem una matriu 8x6 primer indiquem les files i depres les columnes, per ultim indiquem el valor base de totes les caselles

let matriu = Array(6).fill().map(() => Array(8).fill("."));
console.log(matriu)
imprimirTablero(matriu)
function imprimirTablero(matriu){
    var fila
    for (let i=-1;i<9;i++){
        if (i!==-1){
            fila +=i
        }else{
            fila =" "
        }
    }
    console.log(fila)
}