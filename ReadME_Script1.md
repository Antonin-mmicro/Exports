# Analyse des permissions des dossiers

Ce script PowerShell permet de lister de manière récursive les permissions des dossiers à partir d'un chemin donné. Les résultats sont exportés dans un fichier CSV en UTF-8.

## Fonctionnalités

- Demande à l'utilisateur le chemin du dossier à analyser.
- Vérifie si le dossier existe.
- Parcourt tous les dossiers et sous-dossiers.
- Récupère les ACL (Access Control List) pour chaque dossier.
- Exclut les comptes systèmes courants (SYSTEM, Administrateurs, NT SERVICE, etc.).
- Classe les permissions en niveaux : Contrôle total, Modification, Lecture.
- Exporte le résultat dans un fichier CSV UTF-8 avec point-virgule comme séparateur.

## Prérequis

- PowerShell 5.1 ou supérieur
- Droits suffisants pour lire les ACL des dossiers ciblés

## Instructions d'utilisation

1. Ouvrir PowerShell avec les droits nécessaires.
2. Placer le script dans un dossier accessible.
3. Exécuter le script :  
   `.\Sciprt1.ps1`
4. Entrer le chemin complet du dossier à analyser.
5. À la fin de l'analyse, le fichier CSV `Permissions_Dossiers_Recursif.csv` sera généré dans le même dossier que le script.

## Structure du CSV généré

- **Dossier** : Chemin complet du dossier analysé
- **Utilisateur** : Nom de l'utilisateur ou groupe
- **TypeAcces** : Autorisation (Allow / Deny)
- **NiveauPermission** : Niveau de permission (Contrôle total, Modification, Lecture, ou spécifique)

## Remarques

- Le script force l'encodage UTF-8 pour éviter les caractères cassés.
- Les comptes système sont exclus pour simplifier la lecture.
- Le script inclut le dossier racine dans l'analyse.