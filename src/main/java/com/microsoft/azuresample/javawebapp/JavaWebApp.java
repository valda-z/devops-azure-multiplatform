package com.microsoft.azuresample.javawebapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

@SpringBootApplication
public class JavaWebApp {

    public static void main(String[] args) {
        ApplicationContext ctx = SpringApplication.run(JavaWebApp.class, args);
        System.out.println("My Spring Boot app started ...");
    }
}
