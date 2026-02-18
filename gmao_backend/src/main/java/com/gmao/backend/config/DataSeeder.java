package com.gmao.backend.config;

import com.gmao.backend.entity.*;
import com.gmao.backend.repository.BatimentRepository;
import com.gmao.backend.repository.EquipementRepository;
import com.gmao.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

        private final UserRepository userRepository;
        private final BatimentRepository batimentRepository;
        private final EquipementRepository equipementRepository;
        private final PasswordEncoder passwordEncoder;

        @Override
        public void run(String... args) throws Exception {
                if (userRepository.count() == 0) {
                        User admin = User.builder()
                                        .firstName("Admin")
                                        .lastName("System")
                                        .email("admin@gmao.com")
                                        .password(passwordEncoder.encode("admin123"))
                                        .role(Role.ADMIN)
                                        .build();
                        userRepository.save(admin);

                        User manager = User.builder()
                                        .firstName("Manager")
                                        .lastName("One")
                                        .email("manager1@gmail.com")
                                        .password(passwordEncoder.encode("manager123"))
                                        .role(Role.MANAGER)
                                        .build();
                        userRepository.save(manager);

                        User tech = User.builder()
                                        .firstName("Technicien")
                                        .lastName("One")
                                        .email("tech1@gmail.com")
                                        .password(passwordEncoder.encode("tech123"))
                                        .role(Role.TECH)
                                        .build();
                        userRepository.save(tech);

                        System.out.println("Data Seeding: Default users created.");
                        System.out.println("Data Seeding: Default users created.");
                } else {
                        // Fix for existing users with null isActive
                        userRepository.findAll().forEach(user -> {
                                if (user.getIsActive() == null) {
                                        user.setIsActive(true);
                                        userRepository.save(user);
                                        System.out.println("Data Seeding: Fixed null isActive for user "
                                                        + user.getEmail());
                                }
                        });
                }

                if (batimentRepository.count() == 0) {
                        Batiment bat1 = Batiment.builder()
                                        .nom("Siege Social")
                                        .adresse("123 Rue de la Republique")
                                        .description("Bureaux administratifs")
                                        .build();
                        batimentRepository.save(bat1);

                        Batiment bat2 = Batiment.builder()
                                        .nom("Usine Nord")
                                        .adresse("Zone Industrielle Nord")
                                        .description("Production principale")
                                        .build();
                        batimentRepository.save(bat2);

                        System.out.println("Data Seeding: Default batiments created.");

                        if (equipementRepository.count() == 0) {
                                Equipement eq1 = Equipement.builder()
                                                .nom("Climatisation Etage 1")
                                                .type(TypeEquipement.CVC)
                                                .etat(EtatEquipement.FONCTIONNEL)
                                                .batiment(bat1)
                                                .build();
                                equipementRepository.save(eq1);

                                Equipement eq2 = Equipement.builder()
                                                .nom("Robot Assembleur A")
                                                .type(TypeEquipement.AUTRE)
                                                .etat(EtatEquipement.EN_MAINTENANCE)
                                                .batiment(bat2)
                                                .build();
                                equipementRepository.save(eq2);

                                System.out.println("Data Seeding: Default equipements created.");
                        }
                }
                System.out.println("Data Seeding: Default equipements created.");
        }

        private void fixUserActivation(String email) {
                userRepository.findByEmail(email).ifPresent(user -> {
                        if (!Boolean.TRUE.equals(user.getIsActive())) {
                                user.setIsActive(true);
                                userRepository.save(user);
                                System.out.println("Data Seeding: Force activated user " + email);
                        }
                });
        }
}
