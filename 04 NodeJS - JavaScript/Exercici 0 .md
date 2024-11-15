<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Exercici 0

Per practicar JavaScript i orientació a objectes, l'objectiu d'aquest exercici és fer un joc de línia de comandes en Node.js anomenat **"BuscaTresors"**.

## Requisits

Es genera un tauler bidimensional (matriu) de 8x8.

S’amaguen 16 tresors en diverses coordenades aleatòries del tauler.

L'usuari té les següents comandes textuals:

* **ajuda**: mostra les següents opcions
* **carregar partida "nom_arxiu.json"**: carrega una partida guardada
* **guardar partida "nom_guardar.json"**: guarda la partida actual
* **destapar x,y**: on x,y són números, mostra el contingut de la casella x,y **i diu a quina distància està el tresor més proper**
* **puntuació**: mostra la puntuació actual i les tirades restants. Originalment l'usuari té 32 tirades, que es gasten cada vegada que NO encerta un tresor (és a dir trobar un tresor no gasta tirada). 
  
  La puntuació és la quantitat de tresors que ha trobat del total, per exemple: z/32

La partida s'acaba quan:

- L'usuari **acaba les tirades**, que surt el missatge: "Has perdut, queden z tresors"
- L'usuari **destapa tots els tresors**, que surt el missatge: "Has guanyat amb només y tirades"


