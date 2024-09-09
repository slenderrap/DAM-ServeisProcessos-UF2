package com.project;

class Main {
	public static void main (String ... args){
        new ThreadDemo("Info pel thread").start();
	
		new Thread(new Task("Info per la tasca 0"), "Thread 0").start();
		
		new Thread(new Task("Info per la tasca 1"), "Thread 1").start();
	}
}
