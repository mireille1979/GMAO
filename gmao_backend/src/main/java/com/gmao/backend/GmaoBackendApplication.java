package com.gmao.backend;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootApplication
public class GmaoBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(GmaoBackendApplication.class, args);
    }

    @Bean
    CommandLineRunner run(JdbcTemplate jdbcTemplate) {
        return args -> {
            try {
                // FIX: Alter table to allow new roles (CLIENT) by changing ENUM to VARCHAR
                jdbcTemplate.execute("ALTER TABLE users MODIFY COLUMN role VARCHAR(50)");
                System.out.println("✅ MIGRATION SUCCESS: User role column updated to VARCHAR(50)");
            } catch (Exception e) {
                System.out.println("⚠️ MIGRATION SKIPPED: " + e.getMessage());
            }
        };
    }
}
