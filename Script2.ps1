<#
OBJECTIF
Lister les droits NTFS (Lecture / Modification) sur TOUS les dossiers d’un serveur
pour une liste d’utilisateurs AD saisie manuellement.

➡ Lecture seule
➡ Modification / Contrôle

Export :
- CSV clair et exploitable
- Lecture seule (aucune modification)
#>

Import-Module ActiveDirectory

# =========================
# PARAMÈTRES UTILISATEUR
# =========================
$RootPath = Read-Host "Entrez le chemin racine du serveur de fichiers (ex: D:\DATA)"

$inputUsers = Read-Host "Entrez les noms SAM des utilisateurs (séparés par des virgules)"
$UserNames = $inputUsers -split "," | ForEach-Object { $_.Trim() }

# =========================
# RÉSOLUTION UTILISATEURS AD
# =========================
$Users = foreach ($name in $UserNames) {
    try {
        Get-ADUser -Identity $name -ErrorAction Stop
    }
    catch {
        Write-Warning "Utilisateur AD introuvable : $name"
    }
}

if (-not $Users) {
    Write-Host "Aucun utilisateur valide. Arrêt du script." -ForegroundColor Red
    exit
}

# =========================
# PRÉPARATION EXPORT
# =========================
$Results = [System.Collections.ArrayList]@()

Write-Host "`nAnalyse des accès NTFS en cours..." -ForegroundColor Cyan

# =========================
# FONCTION D’ANALYSE
# =========================
function Scan-Folder {
    param ([string]$Path)

    if (-not (Test-Path $Path -PathType Container)) { return }

    try {
        $acl = Get-Acl $Path
    }
    catch {
        return
    }

    foreach ($user in $Users) {
        $rules = $acl.Access | Where-Object {
            $_.IdentityReference -like "*$($user.SamAccountName)*"
        }

        foreach ($rule in $rules) {

            $accessType = if (
                $rule.FileSystemRights -band
                ([System.Security.AccessControl.FileSystemRights]::Modify -bor
                 [System.Security.AccessControl.FileSystemRights]::FullControl)
            ) {
                "Modification"
            }
            else {
                "Lecture"
            }

            $Results.Add([PSCustomObject]@{
                Dossier   = $Path
                Utilisateur = $user.SamAccountName
                Acces     = $accessType
                Herite    = $rule.IsInherited
            }) | Out-Null
        }
    }

    Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Scan-Folder $_.FullName
    }
}

# =========================
# LANCEMENT
# =========================
Scan-Folder -Path $RootPath

# =========================
# EXPORT CSV
# =========================
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = ".\Acces_Serveur_$timestamp.csv"

$Results |
Sort-Object Dossier, Utilisateur |
Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "`nCSV généré : $csvPath" -ForegroundColor Green
Write-Host "Analyse terminée." -ForegroundColor Green
