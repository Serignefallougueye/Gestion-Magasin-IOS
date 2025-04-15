# Gestion de Magasin iOS

Application iOS de gestion de magasin développée avec SwiftUI et CoreData.

## Fonctionnalités

- 👥 Gestion des utilisateurs
  - Création et modification des comptes
  - Gestion des rôles (Magasinier, Gestionnaire de Stock, Responsable Achats)
  - Suivi des statuts utilisateurs 

- 📦 Gestion des produits
  - Catalogue des produits
  - Gestion des stocks
  - Catégorisation des produits

- 🛍️ Gestion des commandes
  - Création de commandes
  - Suivi des livraisons
  - Historique des commandes

- 📊 Rapports et statistiques
  - Vue d'ensemble du stock
  - Analyses des mouvements
  - Rapports personnalisables
 
    

## Technologies utilisées

- SwiftUI
- CoreData
- iOS 16+

## Configuration requise

- Xcode 14+
- iOS 16.0+
- macOS Ventura+

## Installation

1. Clonez le repository
```bash
git clone https://github.com/Serignefallougueye/Gestion-Magasin-IOS.git
```

2. Ouvrez le projet dans Xcode
```bash
cd Gestion-Magasin-IOS
open *.xcodeproj
```

3. Compilez et exécutez l'application

## Structure du projet

- `Features/` : Modules de l'application
  - `Authentication/` : Gestion de l'authentification
  - `Users/` : Gestion des utilisateurs
  - `Products/` : Gestion des produits
  - `Inventory/` : Gestion du stock
  - `Purchases/` : Gestion des commandes
  - `Reports/` : Rapports et statistiques

- `Core/` : Composants principaux
  - `Models/` : Modèles de données
  - `Services/` : Services partagés
  - `Extensions/` : Extensions utilitaires

## Contributions

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Commiter vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails. 
