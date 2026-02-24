1# GMAO Mobile

Application mobile Flutter pour la gestion de maintenance assistée par ordinateur (GMAO).

##  Technologies

| Technologie | Version |
|---|---|
| Flutter / Dart | SDK ^3.9.2 |
| Dio | ^5.9.1 (requêtes HTTP) |
| Provider | ^6.1.5 (gestion d'état) |
| SharedPreferences | ^2.5.4 (stockage local) |
| Google Fonts | ^8.0.1 (typographie) |
| Table Calendar | ^3.1.2 (planning) |

##  Prérequis

1. **Flutter SDK** — [Installation Flutter](https://docs.flutter.dev/get-started/install)
2. **Android Studio** ou **VS Code** avec les extensions Flutter/Dart
3. **Backend GMAO** — Doit être en cours d'exécution (voir `gmao_backend/README.md`)

Vérifiez votre installation :

```bash
flutter doctor
```

##  Lancement

### 1. Installer les dépendances

```bash
cd gmao_mobile
flutter pub get
```

### 2. Lancer l'application

```bash
flutter run
```

##  Connexion au backend selon l'appareil

La configuration de l'URL backend se trouve dans :
`lib/core/api_client.dart`

### Émulateur Android

```dart
return 'http://10.0.2.2:8081/api';
```

> `10.0.2.2` est un alias spécial de l'émulateur Android qui redirige vers le `localhost` du PC.

### Téléphone physique (USB)

Utilisez `adb reverse` pour créer un tunnel USB :

```bash
adb reverse tcp:8081 tcp:8081
```

Puis dans `api_client.dart` :

```dart
return 'http://127.0.0.1:8081/api';
```

>  **Important :** La commande `adb reverse` doit être refaite à chaque reconnexion du téléphone.

### Téléphone physique (WiFi uniquement)

1. Trouvez l'IP de votre PC : `ipconfig` → adresse IPv4 (ex: `192.168.1.181`)
2. Vérifiez que le téléphone et le PC sont sur le **même réseau WiFi**
3. Autorisez le port `8081` dans le **pare-feu Windows** :

```powershell
# (Exécuter en tant qu'administrateur)
New-NetFirewallRule -DisplayName "GMAO Backend 8081" -Direction Inbound -Protocol TCP -LocalPort 8081 -Action Allow
```

4. Dans `api_client.dart` :

```dart
return 'http://[IP_ADDRESS]/api';
```

### Web (navigateur)

```bash
flutter run -d chrome
```

L'URL est automatiquement configurée sur `http://127.0.0.1:8081/api`.

##  Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| **Admin** | `admin@gmao.com` | `admin123` |
| **Manager** | `manager1@gmail.com` | `manager123` |
| **Technicien** | `tech1@gmail.com` | `tech123` |

##  Structure du projet

```
gmao_mobile/
├── lib/
│   ├── main.dart                 # Point d'entrée
│   ├── core/
│   │   ├── api_client.dart       # Configuration HTTP (URL backend, JWT)
│   │   ├── app_router.dart       # Routes de navigation
│   │   └── app_theme.dart        # Thème et couleurs
│   ├── models/                   # Modèles de données
│   ├── providers/                # Gestion d'état (Provider)
│   ├── services/                 # Services API
│   ├── screens/
│   │   ├── auth/                 # Login, Register
│   │   ├── admin/                # Écran administrateur
│   │   ├── manager/              # Dashboard, bâtiments, équipements, etc.
│   │   ├── tech/                 # Liste des tâches, planning technicien
│   │   ├── client/               # Interface client
│   │   └── profile/              # Profil utilisateur
│   └── widgets/                  # Composants réutilisables
├── android/                      # Configuration Android native
├── ios/                          # Configuration iOS native
└── pubspec.yaml                  # Dépendances
```

##  Rôles & navigation

| Rôle | Écran principal | Fonctionnalités |
|---|---|---|
| **Admin** | Dashboard Admin | Gestion complète du système |
| **Manager** | Dashboard Manager | Bâtiments, équipements, planification, équipes, stats |
| **Technicien** | Liste des tâches | Interventions assignées, planning, profil |
| **Client** | Interface Client | Soumission de demandes |

##  Commandes utiles

```bash
# Analyser le code
flutter analyze

# Hot reload (pendant l'exécution)
r    # dans le terminal flutter run

# Hot restart (pendant l'exécution)
R    # dans le terminal flutter run

# Nettoyer le projet
flutter clean
flutter pub get

# Construire l'APK
flutter build apk

# Lister les appareils connectés
flutter devices

# Port forwarding USB
adb reverse tcp:8081 tcp:8081
```

2#  GMAO Backend

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

