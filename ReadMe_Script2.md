# Analyse des droits NTFS pour utilisateurs AD

Ce script PowerShell permet de lister les droits NTFS (Lecture / Modification) sur tous les dossiers d’un serveur pour une liste d’utilisateurs Active Directory spécifiée manuellement.  

Les résultats sont exportés dans un CSV clair et exploitable.

## Fonctionnalités

- Analyse récursive des dossiers à partir d’un chemin racine donné.
- Filtrage par utilisateurs AD spécifiés.
- Identification des droits NTFS :
  - Lecture seule
  - Modification / Contrôle
- Export des résultats dans un fichier CSV horodaté.
- Indique si les droits sont hérités ou non.

## Prérequis

- PowerShell 5.1 ou supérieur
- Module ActiveDirectory installé
- Droits suffisants pour lire les ACL des dossiers ciblés
- Les noms SAM des utilisateurs AD doivent être connus

## Instructions d'utilisation

1. Ouvrir PowerShell avec les droits nécessaires.
2. Placer le script dans un dossier accessible.
3. Exécuter le script :  
   `.\Script2.ps1`
4. Entrer le chemin racine du serveur de fichiers (ex: `D:\DATA`).
5. Entrer la liste des noms SAM des utilisateurs (séparés par des virgules).
6. À la fin de l’analyse, le fichier CSV sera généré dans le même dossier que le script avec un horodatage, par exemple :  
   `Acces_Serveur_20260127_153045.csv`

## Structure du CSV généré

- **Dossier** : Chemin complet du dossier analysé
- **Utilisateur** : Nom SAM de l’utilisateur AD
- **Acces** : Type d’accès (Lecture / Modification)
- **Herite** : Indique si le droit est hérité (`True` / `False`)

## Remarques

- Les utilisateurs introuvables dans AD sont ignorés et un avertissement est affiché.
- Le script ignore les erreurs liées à l’accès aux dossiers non accessibles.
- Le CSV est encodé en UTF-8 pour garantir la compatibilité avec Excel et autres outils.
