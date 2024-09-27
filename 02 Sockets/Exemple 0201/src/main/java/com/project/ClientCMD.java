package com.project;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONObject;
import org.json.JSONArray;

import org.jline.reader.LineReader;
import org.jline.reader.LineReaderBuilder;
import org.jline.reader.UserInterruptException;
import org.jline.reader.EndOfFileException;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

public class ClientCMD extends WebSocketClient {

    private List<String> clientsList;
    private String clientId;

    public ClientCMD(URI serverUri) {
        super(serverUri);
        clientsList = new ArrayList<>();
    }

    @Override
    public void onOpen(ServerHandshake handshakedata) {
        System.out.println("Connected to server.");
    }

    @Override
    public void onMessage(String message) {
        JSONObject msgObj = new JSONObject(message);
        String type = msgObj.getString("type");

        if (type.equals("clients")) {
            JSONArray JSONlist = msgObj.getJSONArray("list");
            String id = msgObj.getString("id");
            clientId = id;

            clientsList.clear();
            for (int i = 0; i < JSONlist.length(); i++) {
                String value = JSONlist.getString(i);
                if (!value.equals(clientId)) {
                    clientsList.add(value);
                }
            }
        } else if (type.equals("bounce")) {
            System.out.println("\nBounce: " + msgObj.getString("message"));
        } else if (type.equals("broadcast")) {
            System.out.println("\nBroadcast: " + msgObj.getString("message"));
            System.out.println("(from: " + msgObj.getString("origin") + ")");
        } else if (type.equals("private")) {
            System.out.println("\nPrivate: " + msgObj.getString("message"));
            System.out.println("(from: " + msgObj.getString("origin") + ")");
        } else if (type.equals("confirmation")) {
            System.out.println("\n[Confirmación]: " + msgObj.getString("message"));
        } else if (type.equals("error")) {
            System.out.println("\n[Error]: " + msgObj.getString("message"));
        }

        // Reimprimir el prompt
        System.out.print("> ");
    }

    @Override
    public void onClose(int code, String reason, boolean remote) {
        System.out.println("Disconnected from server.");
    }

    @Override
    public void onError(Exception ex) {
        ex.printStackTrace();
    }

    public void showHelp() {
        System.out.println("\nAvailable commands (press ↩️ after each command):");
        System.out.println("- listClients↩️ : lists the connected clients");
        System.out.println("- sendPrivate XXX message↩️ : sends a private message to the client with id XXX");
        System.out.println("- sendBroadcast message↩️ : sends a message to all clients");
        System.out.println("- sendBounce message↩️ : sends a message that bounces back to you");
        System.out.println("- exit↩️ : exits the client");
    }

    public void listClients() {
        if (clientsList.isEmpty()) {
            System.out.println("No other clients connected.");
        } else {
            System.out.println("Connected clients:");
            for (String client : clientsList) {
                System.out.println(client);
            }
        }
    }

    public static void main(String[] args) throws URISyntaxException {
        String serverURI = "ws://localhost:3000"; 
        ClientCMD client = new ClientCMD(new URI(serverURI));
        client.connect();

        // Wait for the connection to be established
        while (!client.isOpen()) {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        // After connection is established
        System.out.println("Welcome");
        client.showHelp();

        LineReader reader = LineReaderBuilder.builder().build();

        try {
            while (true) {
                String line = null;
                try {
                    line = reader.readLine("> ");
                } catch (UserInterruptException e) {
                    // Handle Ctrl+C
                    continue;
                } catch (EndOfFileException e) {
                    break;
                }

                line = line.trim();

                if (line.equalsIgnoreCase("help")) {
                    client.showHelp();
                } else if (line.equalsIgnoreCase("listClients")) {
                    client.listClients();
                } else if (line.toLowerCase().startsWith("sendprivate")) {
                    String[] parts = line.split(" ", 3);
                    if (parts.length < 3) {
                        System.out.println("Usage: sendPrivate XXX message");
                        continue;
                    }
                    String destination = parts[1];
                    String message = parts[2];

                    JSONObject obj = new JSONObject();
                    obj.put("type", "private");
                    obj.put("destination", destination);
                    obj.put("message", message);
                    client.send(obj.toString());
                } else if (line.toLowerCase().startsWith("sendbroadcast")) {
                    String[] parts = line.split(" ", 2);
                    if (parts.length < 2) {
                        System.out.println("Usage: sendBroadcast message");
                        continue;
                    }
                    String message = parts[1];

                    JSONObject obj = new JSONObject();
                    obj.put("type", "broadcast");
                    obj.put("message", message);
                    client.send(obj.toString());
                } else if (line.toLowerCase().startsWith("sendbounce")) {
                    String[] parts = line.split(" ", 2);
                    if (parts.length < 2) {
                        System.out.println("Usage: sendBounce message");
                        continue;
                    }
                    String message = parts[1];

                    JSONObject obj = new JSONObject();
                    obj.put("type", "bounce");
                    obj.put("message", message);
                    client.send(obj.toString());
                } else if (line.equalsIgnoreCase("exit")) {
                    System.out.println("Exiting client.");
                    client.close();
                    break;
                } else {
                    System.out.println("Unknown command. Type 'help' to see available commands.");
                }
            }
        } finally {
            System.out.println("Finished");
        }
    }
}
