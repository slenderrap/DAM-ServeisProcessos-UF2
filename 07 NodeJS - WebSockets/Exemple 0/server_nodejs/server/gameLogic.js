'use strict';

const COLORS = ['green', 'blue', 'orange', 'red', 'purple'];
const OBJECT_WIDTH = 0.05;
const OBJECT_HEIGHT = 0.01;
const SPEED = 0.2;

// Map de direccions a vectors de moviment (dx, dy)
const DIRECTIONS = {
    "up":         { dx: 0, dy: -1 },
    "upLeft":     { dx: -1, dy: -1 },
    "left":       { dx: -1, dy: 0 },
    "downLeft":   { dx: -1, dy: 1 },
    "down":       { dx: 0, dy: 1 },
    "downRight":  { dx: 1, dy: 1 },
    "right":      { dx: 1, dy: 0 },
    "upRight":    { dx: 1, dy: -1 },
    "none":       { dx: 0, dy: 0 }
};

class GameLogic {
    constructor() {
        this.objects = [];
        this.clients = new Map();

        // Inicialitzar objectes mòbils amb velocitat inicial 0.1
        for (let i = 0; i < 10; i++) {
            this.objects.push({
                x: Math.random() * (1 - OBJECT_WIDTH),
                y: Math.random() * (1 - OBJECT_HEIGHT),
                width: OBJECT_WIDTH,
                height: OBJECT_HEIGHT,
                speed: SPEED,
                direction: Math.random() > 0.5 ? 1 : -1
            });
        }
    }

    addClient(id) {
        let pos = this.getValidPosition();
        let color = this.getAvailableColor();

        this.clients.set(id, {
            id,
            x: pos.x,
            y: pos.y,
            speed: SPEED, // Velocitat inicial 0.1
            direction: "none",
            color,
            width: 0.05, // Mida inicial dels jugadors
            height: 0.05
        });

        return this.clients.get(id);
    }

    removeClient(id) {
        this.clients.delete(id);
    }

    handleMessage(id, msg) {
        try {
            let obj = JSON.parse(msg);
            if (!obj.type) return;

            const actions = {
                "move": () => this.updateClientDirection(id, obj.direction)
            };

            if (actions[obj.type]) {
                actions[obj.type]();
            } else {
                // console.log(`Missatge desconegut de ${id}: ${JSON.stringify(obj)}`);
            }
        } catch (error) {
            // console.error(`Error processant missatge de ${id}:`, error);
        }
    }

    updateClientDirection(id, direction) {
        if (this.clients.has(id) && DIRECTIONS[direction]) {
            this.clients.get(id).direction = direction;
        }
    }

    updateGame(fps) {
        let deltaTime = 1 / fps; // Temps en segons entre frames

        // Moure objectes
        this.objects.forEach(obj => {
            obj.x += obj.speed * obj.direction * deltaTime;
            if (obj.x <= 0 || obj.x + obj.width >= 1) {
                obj.direction *= -1;
            }
        });

        // Moure clients segons la direcció assignada
        this.clients.forEach(client => {
            let moveVector = DIRECTIONS[client.direction];
            client.x = Math.max(0, Math.min(1, client.x + client.speed * moveVector.dx * deltaTime));
            client.y = Math.max(0, Math.min(1, client.y + client.speed * moveVector.dy * deltaTime));

            // Comprovar col·lisions amb objectes
            this.objects = this.objects.filter(obj => {
                if (this.isColliding(client.x, client.y, client.width, client.height, obj.x, obj.y, obj.width, obj.height)) {
                    // Eliminar objecte i augmentar mida i velocitat del jugador
                    client.width *= 1.1;  // Augmenta un 10%
                    client.height *= 1.1;
                    client.speed *= 1.05; // Augmenta un 5%
                    return false; // Objecte eliminat
                }
                return true; // Objecte es manté
            });
        });
    }

    getValidPosition() {
        let x, y;
        let isValid = false;
        
        while (!isValid) {
            x = Math.random() * (1 - OBJECT_WIDTH);
            y = Math.random() * (1 - OBJECT_HEIGHT);
            isValid = true;

            this.objects.forEach(obj => {
                if (this.isColliding(x, y, OBJECT_WIDTH, OBJECT_HEIGHT, obj.x, obj.y, obj.width, obj.height)) {
                    isValid = false;
                }
            });

            this.clients.forEach(client => {
                if (this.isColliding(x, y, OBJECT_WIDTH, OBJECT_HEIGHT, client.x, client.y, client.width, client.height)) {
                    isValid = false;
                }
            });
        }

        return { x, y };
    }

    getAvailableColor() {
        let assignedColors = new Set(Array.from(this.clients.values()).map(client => client.color));
        let availableColors = COLORS.filter(color => !assignedColors.has(color));

        if (availableColors.length > 0) {
            return availableColors[Math.floor(Math.random() * availableColors.length)];
        } else {
            return COLORS[Math.floor(Math.random() * COLORS.length)]; // Si tots estan ocupats, escollir un aleatori
        }
    }

    isColliding(x1, y1, w1, h1, x2, y2, w2, h2) {
        return !(x1 + w1 < x2 || x1 > x2 + w2 || y1 + h1 < y2 || y1 > y2 + h2);
    }

    getGameState() {
        return {
            objects: this.objects,
            clients: Array.from(this.clients.values())
        };
    }
}

module.exports = GameLogic;
