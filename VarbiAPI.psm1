$Script:ModuleRoot = $PSScriptRoot
$Script:VarbiSettingsFilePath = "$env:TEMP\VarbiAPISettings-$($env:USERNAME)_$($env:COMPUTERNAME).csv"

$Private = @(Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in @($Private + $Public)) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

if (-not (Test-Path $VarbiSettingsFilePath)) {

    Clear-Host
    Write-Output "Select credential file for encrypted API key"
    $APIKeyPath= Get-FilePath

    $Server = Read-Host -Prompt "Enter server URI (e.g: ""https://api.varbi.com/v1"")"

    $Table = [PSCustomObject]@{
        APIKeyPath   = $APIKeyPath
        Server       = $Server
    }

    $Table | ConvertTo-Csv -NoTypeInformation | Set-Content -Path $VarbiSettingsFilePath -Encoding UTF8

    $Script:Settings = Import-Csv -Path $VarbiSettingsFilePath
}
else {
    $Script:Settings = Import-Csv -Path $VarbiSettingsFilePath
}

Export-ModuleMember -Function $Public.Basename -Variable Settings