# 📱 GMAO Mobile

Application mobile Flutter pour la gestion de maintenance assistée par ordinateur (GMAO).

## 📋 Technologies

| Technologie | Version |
|---|---|
| Flutter / Dart | SDK ^3.9.2 |
| Dio | ^5.9.1 (requêtes HTTP) |
| Provider | ^6.1.5 (gestion d'état) |
| SharedPreferences | ^2.5.4 (stockage local) |
| Google Fonts | ^8.0.1 (typographie) |
| Table Calendar | ^3.1.2 (planning) |

## ⚙️ Prérequis

1. **Flutter SDK** — [Installation Flutter](https://docs.flutter.dev/get-started/install)
2. **Android Studio** ou **VS Code** avec les extensions Flutter/Dart
3. **Backend GMAO** — Doit être en cours d'exécution (voir `gmao_backend/README.md`)

Vérifiez votre installation :

```bash
flutter doctor
```

## 🚀 Lancement

### 1. Installer les dépendances

```bash
cd gmao_mobile
flutter pub get
```

### 2. Lancer l'application

```bash
flutter run
```

## 📲 Connexion au backend selon l'appareil

La configuration de l'URL backend se trouve dans :
`lib/core/api_client.dart`

### Émulateur Android



> `10.0.2.2` est un alias spécial de l'émulateur Android qui redirige vers le `localhost` du PC.

### Téléphone physique (USB)

Utilisez `adb reverse` pour créer un tunnel USB :

```bash
adb reverse tcp:8081 tcp:8081
```

Puis dans `api_client.dart` :



> ⚠️ **Important :** La commande `adb reverse` doit être refaite à chaque reconnexion du téléphone.

### Téléphone physique (WiFi uniquement)

1. Trouvez l'IP de votre PC : `ipconfig` → adresse IPv4 (ex: `192.168.1.181`)
2. Vérifiez que le téléphone et le PC sont sur le **même réseau WiFi**
3. Autorisez le port `8081` dans le **pare-feu Windows** :

```powershell
# (Exécuter en tant qu'administrateur)
New-NetFirewallRule -DisplayName "GMAO Backend 8081" -Direction Inbound -Protocol TCP -LocalPort 8081 -Action Allow
```

4. Dans `api_client.dart` :



### Web (navigateur)

```bash
flutter run -d chrome
```

L'URL est automatiquement configurée sur `http://127.0.0.1:8081/api`.

## 👥 Comptes de test

| Rôle | Email | Mot de passe |
|---|---|---|
| **Admin** | `admin@gmao.com` | `admin123` |
| **Manager** | `manager1@gmail.com` | `manager123` |
| **Technicien** | `tech1@gmail.com` | `tech123` |

## 📁 Structure du projet

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

## 🧭 Rôles & navigation

| Rôle | Écran principal | Fonctionnalités |
|---|---|---|
| **Admin** | Dashboard Admin | Gestion complète du système |
| **Manager** | Dashboard Manager | Bâtiments, équipements, planification, équipes, stats |
| **Technicien** | Liste des tâches | Interventions assignées, planning, profil |
| **Client** | Interface Client | Soumission de demandes |

## 🛠️ Commandes utiles

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

## ⚠️ Résolution de problèmes

| Problème | Solution |
|---|---|
| `Connection timeout` sur téléphone | Vérifier `adb reverse tcp:8081 tcp:8081` ou l'IP dans `api_client.dart` |
| `10.0.2.2` ne fonctionne pas | Cette adresse ne marche que sur l'**émulateur**, pas sur un vrai téléphone |
| Erreur Gradle `InvalidPathException` | `flutter clean` + supprimer `android/.gradle/` + `flutter pub get` |
| `Could not find a generator` | `flutter pub get` |
| Écran blanc au lancement | Vérifier que le backend est démarré et accessible |
