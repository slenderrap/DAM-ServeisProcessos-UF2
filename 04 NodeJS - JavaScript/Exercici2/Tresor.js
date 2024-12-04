class Casella {
    constructor (posicioX, posicioY, descoberta=false,trampa=false){
        this.posicioX=posicioX
        this.posicioY=posicioY
        this.descoberta=descoberta
        this.trampa=trampa
    }
    destapar(){
        if (!this.descoberta){
            this.descoberta=true
            console.log("La proxima vegada tindras mes sort")
        }
        else{
            console.error("Ja estava destapada")
        }
    }
    setTrampa(){
        if (this.trampa===false){
            this.trampa=true
        }else{
            this.trampa=false
        }
    }
    toString(){
        if (this.descoberta || this.trampa){
            return "_"
        }else{
            return "."
        }
    }


}

class Tresor extends Casella{
    constructor (posicioX, posicioY, descoberta=false,trampa=false){
        super(posicioX,posicioY)
        this.descoberta=descoberta
        this.trampa=trampa
    }
    destapar(){
        if (!this.descoberta){
            this.descoberta=true
            console.log("Has trovat un tresor!")
        }
        else{
            console.error("Ja estava obert")
        }
    }
    setTrampa(){
        if (this.trampa===false){
            this.trampa=true
        }else{
            this.trampa=false
        }
    }
    toString(){
        if (this.descoberta||this.trampa){
            return "!"
        }else{
            return "."
        }
    }
}


module.exports = {Tresor, Casella}