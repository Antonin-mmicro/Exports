$path = Read-Host "Entrez le chemin du dossier à analyser"

if (-Not (Test-Path $path)) {
    Write-Host "Le chemin spécifié n'existe pas." -ForegroundColor Red
    exit
}

$systemPatterns = @(
    "^NT AUTHORITY\\",
    "^BUILTIN\\Administrators$",
    "^BUILTIN\\Users$",
    "^CREATOR OWNER$",
    "^NT SERVICE\\",
    "Système$",
    "SYSTEM$"
)

$ignoreFolders = @(
    '$Recycle.Bin',
    'System Volume Information',
    'Config.Msi',
    'Documents and Settings',
    'Recovery'
)

$maxLines = 15000
$currentLineCount = 0
$fileIndex = 1

function Get-NewPath {
    return Join-Path $PSScriptRoot ("Permissions_Par_Utilisateur_{0}.csv" -f $script:fileIndex)
}

$csvPath = Get-NewPath

$writer = New-Object System.IO.StreamWriter($csvPath, $false, (New-Object System.Text.UTF8Encoding($true)))

$writer.WriteLine("Dossier;Permissions")
$currentLineCount = 1

function Close-And-NewFile {
    $writer.Close()
    $script:fileIndex++
    $script:csvPath = Get-NewPath
    $script:writer = New-Object System.IO.StreamWriter($script:csvPath, $false, (New-Object System.Text.UTF8Encoding($true)))
    $script:writer.WriteLine("Dossier;Permissions")
    $script:currentLineCount = 1
}

function Get-PermissionText($rights) {
    if ($rights -band [System.Security.AccessControl.FileSystemRights]::FullControl) { return "Controle total" }
    elseif ($rights -band [System.Security.AccessControl.FileSystemRights]::Modify) { return "Modification" }
    elseif ($rights -band [System.Security.AccessControl.FileSystemRights]::ReadAndExecute -or
            $rights -band [System.Security.AccessControl.FileSystemRights]::Read) { return "Lecture" }
    else { return $null }
}

function Write-LineCSV($line) {
    if ($script:currentLineCount -ge $script:maxLines) {
        Close-And-NewFile
    }
    $script:writer.WriteLine($line)
    $script:currentLineCount++
}

function ProcessFolder($folder) {
    if (-Not (Test-Path $folder)) { return }

    $folderPath = if ($folder -notmatch "^\\\\\?\\") { "\\?\$folder" } else { $folder }

    try {
        $acl = Get-Acl -LiteralPath $folderPath -ErrorAction Stop
    } catch {
        return
    }

    $entries = @()

    foreach ($entry in $acl.Access) {
        $identity = $entry.IdentityReference.Value

        if ($systemPatterns | Where-Object { $identity -match $_ }) { continue }

        $perm = Get-PermissionText $entry.FileSystemRights
        if ($perm) { $entries += "${identity}:${perm}" }
    }

    if ($entries.Count -gt 0) {
        $csvLine = "$folder;$(($entries -join ';'))"
        Write-LineCSV $csvLine
    }

    try {
        foreach ($sub in [System.IO.Directory]::EnumerateDirectories($folderPath)) {
            if ($ignoreFolders -notcontains [IO.Path]::GetFileName($sub)) {
                ProcessFolder $sub
            }
        }
    } catch {
        return
    }
}

Write-Host "Analyse en cours..." -ForegroundColor Cyan
ProcessFolder $path

$writer.Close()

Write-Host "`nAnalyse terminée !" -ForegroundColor Green
Write-Host "Fichiers générés :" -ForegroundColor Yellow
for ($i=1; $i -le $fileIndex; $i++) {
    Write-Host "  Permissions_Par_Utilisateur_$i.csv"
}
