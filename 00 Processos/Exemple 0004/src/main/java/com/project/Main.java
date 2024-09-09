package com.project;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

public class Main {
    public static void main(String[] args) {
        // Primer CompletableFuture: retorna un número després d'una operació asíncrona
        CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> {
            System.out.println("Tasques en Future1...");
            return 10;
        });

        // Segon CompletableFuture: suma 5 al resultat del primer
        CompletableFuture<Integer> future2 = future1.thenApply(result -> {
            System.out.println("Tasques en Future2...");
            return result + 5;
        });

        // Tercer CompletableFuture: multiplica el resultat anterior per 2
        CompletableFuture<Integer> future3 = future2.thenApply(result -> {
            System.out.println("Tasques en Future3...");
            return result * 2;
        });

        // Executar el càlcul final
        try {
            Integer finalResult = future3.get(); // Bloqueja fins que finalitza
            System.out.println("Resultat final: " + finalResult);
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
    }
}