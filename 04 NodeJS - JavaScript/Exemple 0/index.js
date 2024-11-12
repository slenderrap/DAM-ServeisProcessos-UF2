const fs = require('fs').promises;

async function writeData(obj, file_path) {
    try {
        // Transformar l'objecte a text tipus .json
        const txtData = JSON.stringify(obj, null, 2);

        await fs.writeFile(file_path, txtData, 'utf-8');
        console.log("Dades escrites a data.json");
    } catch (error) {
        console.error("Error en escriure les dades:", error);
    }
}

async function readData(file_path) {
    try {
        const txtData = await fs.readFile(file_path, 'utf-8');

        // Transformar el text a objecte
        const data = JSON.parse(txtData);
        return data
    } catch (error) {
        console.error("Error en llegir les dades:", error);
    }
}

async function main() {

    const person = {
        name: "Maria",
        age: 25,
        city: "Barcelona"
    };

    path = "./maria.json"

    await writeData(person, path)

    json_data = await readData(path)

    console.log(json_data)
}

main()