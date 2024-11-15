<div style="display: flex; width: 100%;">
    <div style="flex: 1; padding: 0px;">
        <p>© Albert Palacios Jiménez, 2024</p>
    </div>
    <div style="flex: 1; padding: 0px; text-align: right;">
        <img src="./assets/ieti.png" height="32" alt="Logo de IETI" style="max-height: 32px;">
    </div>
</div>
<br/>

# Exercici 3

Un servidor web ha de gestionar l'accés concurrent a una pàgina amb contingut limitat. Per evitar una sobrecàrrega, es limita el nombre màxim de connexions simultànies a la pàgina.

**Objectiu**

Implementa un sistema en Java que limiti el nombre de connexions simultànies a una pàgina web utilitzant un semàfor.

**Requisits**

- Crea una classe Java amb un mètode main.

- Defineix una classe WebPage que contingui un semàfor que limiti el nombre de connexions simultànies.

- Defineix tasques (Runnable) que simulin les connexions d'usuaris a la pàgina web. Cada connexió ha d'adquirir un permís abans d'accedir a la pàgina i l'ha de lliurar quan es desconnecta.

- Simula múltiples connexions concurrentment utilitzant un ExecutorService amb un pool de fils.

- Mostra a la consola quan una connexió s'estableix, quan es desconnecta i quan una connexió ha d'esperar perquè s'han superat les connexions màximes permeses.

- Assegura't de tancar l'executor al final.

**Important**: Fes servir el format MVN habitual, i no t'oblidis dels arxius 'run.ps1' i 'run.sh'