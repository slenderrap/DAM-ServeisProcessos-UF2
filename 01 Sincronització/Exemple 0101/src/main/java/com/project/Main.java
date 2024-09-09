package com.project;

import java.util.concurrent.Semaphore;
import com.project.LongRunningTask;

public class Main {

    private static final Semaphore semaphore = new Semaphore(0); 

    public static void main(String[] args) {

        System.out.println("Llançant LongRunningTask...");

        // Llançar la tasca de duració indeterminada
        LongRunningTask task = new LongRunningTask(semaphore);
        task.start();

        try {
            // Intentar adquirir el semàfor. Això bloquejarà fins que la tasca alliberi el semàfor.
            System.out.println("Esperant que LongRunningTask acabi...");
            semaphore.acquire();  // Esperar fins que el fil alliberi el semàfor
            System.out.println("LongRunningTask ha alliberat el semàfor. Continuant amb l'execució.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}