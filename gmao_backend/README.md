#  GMAO Backend

API REST pour la gestion de maintenance assistée par ordinateur (GMAO).

##  Technologies

| Technologie | Version |
|---|---|
| Java | 17 |
| Spring Boot | 3.2.2 |
| Maven | 3.9.6 (inclus dans `tools/`) |
| MySQL | 5.7+ (via XAMPP) |
| Lombok | 1.18.36 |
| JWT (jjwt) | 0.11.5 |

##  Prérequis

1. **JDK 17** — Installé dans `C:\Program Files\Java\jdk-21` (ou modifier `start_backend.bat`)
2. **XAMPP** — MySQL doit être démarré sur le port `3306`
3. **Base de données** — `gmao_db` (créée automatiquement au premier lancement)

##  Lancement

### Option 1 : Script batch (recommandé)

Depuis la racine du projet (`GMAO/`) :

```bash
start_backend.bat
```

Ce script configure automatiquement `JAVA_HOME`, `MAVEN_HOME` et lance le backend.

### Option 2 : Manuellement

```bash
cd gmao_backend
mvn spring-boot:run
```

> **Note :** Maven doit être dans le `PATH`, ou utiliser le Maven embarqué dans `tools/apache-maven-3.9.6`.

### Vérification

Le serveur démarre sur **http://localhost:8081**. Testez avec :

```bash
curl http://localhost:8081/api/auth/authenticate
```

##  Configuration Base de Données

Fichier : `src/main/resources/application.properties`

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/gmao_db?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=
```

- **URL** : `localhost:3306` (XAMPP par défaut)
- **Utilisateur** : `root`
- **Mot de passe** : vide (par défaut XAMPP)
- **DDL** : `update` — les tables sont créées/mises à jour automatiquement au démarrage

> Pour changer la base de données, modifiez `application.properties` avant le lancement.

##   Authentification (JWT)

L'API utilise des tokens JWT. Le token expire après **24 heures** (86400000 ms).

### Endpoints publics (sans token)

| Méthode | URL | Description |
|---|---|---|
| `POST` | `/api/auth/authenticate` | Connexion |
| `POST` | `/api/auth/register` | Inscription |
| `GET` | `/api/postes` | Liste des postes |

### Connexion

```bash
curl -X POST http://localhost:8081/api/auth/authenticate \
  -H "Content-Type: application/json" \
  -d '{"email": "manager1@gmail.com", "password": "manager123"}'
```

Réponse : `{ "token": "eyJhbG..." }`

### Utilisation du token

```bash
curl http://localhost:8081/api/equipements \
  -H "Authorization: Bearer <votre_token>"
```

##   Comptes par défaut

Créés automatiquement au démarrage par `DataSeeder.java` :

| Rôle | Email | Mot de passe |
|---|---|---|
| **Admin** | `admin@gmao.com` | `admin123` |
| **Manager** | `manager1@gmail.com` | `manager123` |
| **Technicien** | `tech1@gmail.com` | `tech123` |

##    Modules API

| Module | Endpoint de base | Description |
|---|---|---|
| Auth | `/api/auth/` | Authentification & inscription |
| Bâtiments | `/api/batiments/` | Gestion des bâtiments |
| Équipements | `/api/equipements/` | Gestion des équipements |
| Zones | `/api/zones/` | Gestion des zones |
| Interventions | `/api/interventions/` | Gestion des interventions |
| Demandes | `/api/demandes/` | Demandes d'intervention |
| Équipes | `/api/equipes/` | Gestion des équipes |
| Utilisateurs | `/api/users/` | Gestion des utilisateurs |
| Postes | `/api/postes/` | Postes / fonctions |
| Absences | `/api/absences/` | Gestion des absences |
| Notifications | `/api/notifications/` | Notifications |
| Stats | `/api/stats/` | Statistiques / tableau de bord |
| Export | `/api/export/` | Export de rapports |

##   Structure du projet

```
gmao_backend/
├── src/main/java/com/gmao/backend/
│   ├── config/          # Configuration sécurité, JWT, DataSeeder
│   ├── controller/      # Contrôleurs REST (13 modules)
│   ├── dto/             # Objets de transfert de données
│   ├── model/           # Entités JPA (User, Batiment, Equipement, etc.)
│   ├── repository/      # Repositories JPA
│   └── service/         # Logique métier
├── src/main/resources/
│   └── application.properties
└── pom.xml
```

##  Commandes utiles

```bash
# Compiler sans lancer
mvn clean compile

# Lancer les tests
mvn test

# Créer le JAR
mvn clean package -DskipTests

# Lancer le JAR
java -jar target/gmao-backend-0.0.1-SNAPSHOT.jar
```

