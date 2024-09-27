package com.project;

import org.java_websocket.server.WebSocketServer;
import org.jline.reader.EndOfFileException;
import org.jline.reader.LineReader;
import org.jline.reader.LineReaderBuilder;
import org.jline.reader.UserInterruptException;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;

import java.net.InetSocketAddress;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import org.json.JSONArray;
import org.json.JSONObject;
import org.java_websocket.exceptions.WebsocketNotConnectedException;

public class Server extends WebSocketServer {

    // Map to keep track of connected clients
    private Map<WebSocket, String> clients;
    private static AtomicInteger clientIdCounter = new AtomicInteger(1);

    public Server(InetSocketAddress address) {
        super(address);
        clients = new ConcurrentHashMap<>();
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        String clientId = "client" + clientIdCounter.getAndIncrement();
        clients.put(conn, clientId);
        System.out.println("WebSocket client connected: " + clientId);
        sendClientsList();
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        String clientId = clients.get(conn);
        clients.remove(conn);
        System.out.println("WebSocket client disconnected: " + clientId);
        sendClientsList();
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        String clientId = clients.get(conn);
        JSONObject obj = new JSONObject(message);

        if (obj.has("type")) {
            String type = obj.getString("type");
            if (type.equals("bounce")) {
                JSONObject rst = new JSONObject();
                rst.put("type", "bounce");
                rst.put("message", obj.getString("message"));
                conn.send(rst.toString());

            } else if (type.equals("broadcast")) {
                JSONObject rst = new JSONObject();
                rst.put("type", "broadcast");
                rst.put("origin", clientId);
                rst.put("message", obj.getString("message"));

                // Broadcast to all clients except the sender
                broadcastMessage(rst.toString(), conn);

            } else if (type.equals("private")) {
                String destination = obj.getString("destination");
                JSONObject rst = new JSONObject();
                rst.put("type", "private");
                rst.put("origin", clientId);
                rst.put("destination", destination);
                rst.put("message", obj.getString("message"));

                // Send private message
                sendPrivateMessage(destination, rst.toString(), conn);
            }
        }
    }

    private void broadcastMessage(String message, WebSocket sender) {
        for (Map.Entry<WebSocket, String> entry : clients.entrySet()) {
            WebSocket conn = entry.getKey();
            if (conn != sender) {
                try {
                    conn.send(message);
                } catch (WebsocketNotConnectedException e) {
                    System.out.println("Cliente " + entry.getValue() + " ya no está conectado. Removiendo de la lista.");
                    clients.remove(conn);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void sendPrivateMessage(String destination, String message, WebSocket senderConn) {
        boolean found = false;

        for (Map.Entry<WebSocket, String> entry : clients.entrySet()) {
            if (entry.getValue().equals(destination)) {
                found = true;
                try {
                    entry.getKey().send(message);
                    // Enviar confirmación al remitente
                    JSONObject confirmation = new JSONObject();
                    confirmation.put("type", "confirmation");
                    confirmation.put("message", "Mensaje entregado a " + destination);
                    senderConn.send(confirmation.toString());
                } catch (WebsocketNotConnectedException e) {
                    System.out.println("Cliente " + destination + " ya no está conectado. Removiendo de la lista.");
                    clients.remove(entry.getKey());
                    notifySenderClientUnavailable(senderConn, destination);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            }
        }

        if (!found) {
            System.out.println("Cliente destino " + destination + " no encontrado.");
            notifySenderClientUnavailable(senderConn, destination);
        }
    }

    private void notifySenderClientUnavailable(WebSocket sender, String destination) {
        JSONObject rst = new JSONObject();
        rst.put("type", "error");
        rst.put("message", "El cliente destino " + destination + " no está disponible.");

        try {
            sender.send(rst.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void sendClientsList() {
        JSONArray clientList = new JSONArray();
        for (String clientId : clients.values()) {
            clientList.put(clientId);
        }

        Iterator<Map.Entry<WebSocket, String>> iterator = clients.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<WebSocket, String> entry = iterator.next();
            WebSocket conn = entry.getKey();
            String clientId = entry.getValue();

            JSONObject rst = new JSONObject();
            rst.put("type", "clients");
            rst.put("id", clientId);
            rst.put("list", clientList);

            try {
                conn.send(rst.toString());
            } catch (WebsocketNotConnectedException e) {
                System.out.println("Cliente " + clientId + " ya no está conectado. Removiendo de la lista.");
                iterator.remove();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        ex.printStackTrace();
        // Handle errors as needed
    }

    @Override
    public void onStart() {
        System.out.println("WebSocket server started on port: " + getPort());
        setConnectionLostTimeout(0);
        setConnectionLostTimeout(100);
    }

    public static void main(String[] args) {
        int port = 3000; // Ajusta si el teu servidor s'executa en un port diferent
        Server server = new Server(new InetSocketAddress(port));
        server.start();

        // Crear un LineReader per llegir les comandes de la consola
        LineReader reader = LineReaderBuilder.builder().build();

        System.out.println("El servidor està en funcionament. Escriu 'exit' per aturar-lo.");

        try {
            while (true) {
                String line = null;
                try {
                    line = reader.readLine("> ");
                } catch (UserInterruptException e) {
                    // L'usuari ha pressionat Ctrl+C
                    continue;
                } catch (EndOfFileException e) {
                    // L'usuari ha pressionat Ctrl+D
                    break;
                }

                line = line.trim();

                if (line.equalsIgnoreCase("exit")) {
                    System.out.println("Aturant el servidor...");
                    try {
                        server.stop(1000); // Atura el servidor amb un temps d'espera de 1 segon
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    break;
                } else {
                    System.out.println("Comanda desconeguda. Escriu 'exit' per aturar el servidor.");
                }
            }
        } finally {
            System.out.println("Servidor aturat.");
        }
    }
}
