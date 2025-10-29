# Garage Sale Products - Flutter Riverpod App

Application Flutter de gestion de produits de vente de garage avec panier d'achat, développée avec Riverpod pour la gestion d'état.

## Aperçu du projet

Cette application permet de :
- Afficher une liste de produits de vente de garage
- Ajouter des produits au panier
- Retirer des produits du panier
- Afficher le nombre d'articles dans le panier
- Gérer l'état global avec Riverpod

### Fonctionnalités principales
- **Page d'accueil** : Liste des produits disponibles
- **Panier** : Gestion des produits ajoutés
- **Navigation** : Entre la liste de produits et le panier
- 
---

### Commandes utiles

#### Développement
```bash
# Lancer avec hot reload
flutter run

# Nettoyer le projet
flutter clean

# Réinstaller les dépendances
flutter pub get

# Regénérer les fichiers .g.dart
dart run build_runner build --delete-conflicting-outputs
```

#### Build
```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Build Web
flutter build web
```


### Dépannage

#### Erreur "part of" manquant
Assurez-vous que chaque fichier avec @riverpod contient :
```dart
part 'nom_du_fichier.g.dart';
```

#### Erreur de package
```bash
flutter clean
flutter pub get
```

---

## Ressources

- [Documentation Flutter](https://docs.flutter.dev)
- [Documentation Riverpod](https://riverpod.dev)
- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)

---

## Licence

Ce projet est un exemple éducatif basé sur le cours Net Ninja.