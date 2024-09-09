package com.project;

import java.util.concurrent.Semaphore;

public class LongRunningTask extends Thread {
    private final Semaphore semaphore;

    public LongRunningTask(Semaphore semaphore) {
        this.semaphore = semaphore;
    }

    @Override
    public void run() {
        try {
            // Simular un treball amb duració indeterminada (per exemple, de 2 a 10 segons)
            int duration = (int) (Math.random() * 8000) + 2000;
            System.out.println("LongRunningTask ha començat. Durada aproximada: " + duration / 1000 + " segons");

            // Mostrem un compte enrere
            int remainingTime = duration / 1000;
            System.out.print("Temps restant: ");
            while (remainingTime > 0) {
                System.out.print(remainingTime + " / ");
                Thread.sleep(1000); // Esperem 1 segon
                remainingTime--;
            }
            System.out.println("");

            // Un cop acaba el compte enrere, indiquem que la tasca ha acabat
            System.out.println("LongRunningTask ha acabat. Alliberant semàfor...");

            // Alliberar el semàfor quan acaba
            semaphore.release();  
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
