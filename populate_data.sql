-- 1. Nettoyage (Optionnel - décommentez si vous voulez repartir de zéro)
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE interventions;
-- TRUNCATE TABLE equipements;
-- TRUNCATE TABLE batiments;
-- TRUNCATE TABLE users;
-- SET FOREIGN_KEY_CHECKS = 1;

-- 2. Création des Utilisateurs (Mot de passe pour tous : "password123")
-- Le mot de passe haché est : $2a$10$D8R1.9/c.j/P9.u/M9/e/u/t/e/s/t 

INSERT INTO users (email, password, first_name, last_name, role, created_at, updated_at) VALUES 
('admin@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Admin', 'Global', 'ADMIN', NOW(), NOW()),
('manager@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Alice', 'Manager', 'MANAGER', NOW(), NOW()),
('tech1@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Bob', 'Technicien', 'TECH', NOW(), NOW()),
('tech2@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Charlie', 'Technicien', 'TECH', NOW(), NOW()),

-- Nouveaux Utilisateurs
('admin2@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Super', 'Admin', 'ADMIN', NOW(), NOW()),
('manager2@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'David', 'Responsable', 'MANAGER', NOW(), NOW()),
('tech3@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Eva', 'Maintenance', 'TECH', NOW(), NOW()),
('tech4@gmao.com', '$2a$10$slYQmyNdGzTn7ZLBXBChFOC9f6kFjAqPhccnP6DxlWXx2lPk1C3G6', 'Frank', 'Réparateur', 'TECH', NOW(), NOW());

-- 3. Création des Bâtiments
INSERT INTO batiments (nom, adresse, description) VALUES 
('Siège Social', '123 Avenue de la République, Paris', 'Bureaux administratifs et direction'),
('Usine Nord', 'Zone Industrielle, Lille', 'Site de production principal'),
('Entrepôt Sud', '45 Rue des Docks, Marseille', 'Stockage et logistique');

-- 4. Création des Équipements
-- Supposons les IDs des bâtiments : 1 (Siège), 2 (Usine), 3 (Entrepôt)

INSERT INTO equipements (nom, type, etat, batiment_id) VALUES 
('Ascenseur Principal', 'ASCENSEUR', 'FONCTIONNEL', 1),
('Climatisation Étage 1', 'CVC', 'EN_PANNE', 1),
('Chaudière Industrielle', 'PLOMBERIE', 'FONCTIONNEL', 2),
('Bras Robotique A', 'ELECTRIQUE', 'EN_MAINTENANCE', 2),
('Système Incendie', 'AUTRE', 'FONCTIONNEL', 3),
('Portail Automatique', 'ELECTRIQUE', 'FONCTIONNEL', 3);

-- 5. Création des Interventions
-- Supposons les IDs :
-- Equipements : 1..6
-- Users : 1 (Admin), 2 (Manager), 3 (Tech1), 4 (Tech2)

-- 4. Interventions (Utilisation de sous-requêtes pour trouver les IDs automatiquement)

INSERT INTO interventions (titre, description, priorite, statut, date_prevue, equipement_id, batiment_id, technicien_id, manager_id) VALUES 
-- Maintenance Ascenseur (Tech: Bob, Manager: Alice)
('Maintenance Ascenseur', 'Vérification câbles', 'MOYENNE', 'PLANIFIEE', DATE_ADD(NOW(), INTERVAL 2 DAY), 
    (SELECT id FROM equipements WHERE nom = 'Ascenseur Principal' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Siège Social' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech1@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
),

-- Réparation Clim (Tech: Charlie, Manager: Alice)
('Réparation Clim', 'Ne refroidit plus', 'URGENTE', 'EN_COURS', NOW(), 
    (SELECT id FROM equipements WHERE nom = 'Climatisation Étage 1' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Siège Social' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech2@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
),

-- Calibrage Robot (Tech: Charlie, Manager: Alice)
('Calibrage Robot', 'Recalibrage axes', 'MOYENNE', 'PLANIFIEE', DATE_ADD(NOW(), INTERVAL 7 DAY), 
    (SELECT id FROM equipements WHERE nom = 'Bras Robotique A' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Usine Nord' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech2@gmao.com' LIMIT 1),

-- Nouveaux Bâtiments
INSERT INTO batiments (nom, adresse, description) VALUES 
('Atelier Central', '14 Rue de l''Industrie, Lyon', 'Maintenance et réparations lourdes'),
('Laboratoire R&D', 'Technopôle, Sophia Antipolis', 'Recherche et Développement');

-- Nouveaux Équipements
INSERT INTO equipements (nom, type, etat, batiment_id) VALUES 
('Tour à commande numérique', 'ELECTRIQUE', 'FONCTIONNEL', (SELECT id FROM batiments WHERE nom = 'Atelier Central' LIMIT 1)),
('Groupe Électrogène Secours', 'ELECTRIQUE', 'EN_MAINTENANCE', (SELECT id FROM batiments WHERE nom = 'Atelier Central' LIMIT 1)),
('Spectromètre de masse', 'AUTRE', 'FONCTIONNEL', (SELECT id FROM batiments WHERE nom = 'Laboratoire R&D' LIMIT 1)),
('Imprimante 3D Industrielle', 'ELECTRIQUE', 'EN_PANNE', (SELECT id FROM batiments WHERE nom = 'Laboratoire R&D' LIMIT 1));

-- Nouvelles Interventions
INSERT INTO interventions (titre, description, priorite, statut, date_prevue, equipement_id, batiment_id, technicien_id, manager_id) VALUES 
('Révision Tour CNC', 'Vidange fluide coupe et calibrage.', 'MOYENNE', 'PLANIFIEE', DATE_ADD(NOW(), INTERVAL 3 DAY),
    (SELECT id FROM equipements WHERE nom = 'Tour à commande numérique' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Atelier Central' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech1@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
),
('Test charge Groupe Électrogène', 'Test en charge réelle 1h.', 'HAUTE', 'TERMINEE', DATE_SUB(NOW(), INTERVAL 2 DAY),
    (SELECT id FROM equipements WHERE nom = 'Groupe Électrogène Secours' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Atelier Central' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech2@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
),
('Réparation buse Imprimante 3D', 'Buse bouchée, remplacement nécessaire.', 'URGENTE', 'EN_COURS', NOW(),
    (SELECT id FROM equipements WHERE nom = 'Imprimante 3D Industrielle' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Laboratoire R&D' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech1@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
),
('Calibration Spectromètre', 'Verification annuelle certifiée.', 'BASSE', 'PLANIFIEE', DATE_ADD(NOW(), INTERVAL 1 MONTH),
    (SELECT id FROM equipements WHERE nom = 'Spectromètre de masse' LIMIT 1),
    (SELECT id FROM batiments WHERE nom = 'Laboratoire R&D' LIMIT 1),
    (SELECT id FROM users WHERE email = 'tech2@gmao.com' LIMIT 1),
    (SELECT id FROM users WHERE email = 'manager@gmao.com' LIMIT 1)
);
