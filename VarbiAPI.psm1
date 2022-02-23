$Script:ModuleRoot = $PSScriptRoot
$Script:VarbiCheckSettingsFilePath = "$env:TEMP\VarbiCheck-$($env:USERNAME)_$($env:COMPUTERNAME).checkfile"
$SettingsFileExists = $false

$Private = @(Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Public  = @(Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Nested  = @(Get-ChildItem -Path $ModuleRoot\Resources\SecretClixml\Public\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in @($Private + $Public + $Nested)) {
    try {
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

if (-not (Test-Path $VarbiCheckSettingsFilePath)) {
    Write-Warning -Message "No settings file found. Please configure the module by running Initialize-SettingsFile provided with your information."
    Export-ModuleMember -Function New-Secret, Get-Secret, Initialize-SettingsFile
}
elseif (-not (Test-Path -Path $(Get-Content -Path $VarbiCheckSettingsFilePath))) {
    Write-Warning -Message "No settings file found. Please configure the module by running Initialize-SettingsFile provided with your information."
    Export-ModuleMember -Function New-Secret, Get-Secret, Initialize-SettingsFile
}
else {
    $Script:Settings     = Import-Csv -Path (Get-Content -Path $VarbiCheckSettingsFilePath)
    $Script:ADProperties = @($Settings.PSObject.Properties | Where-Object {($_.Name -notlike '*Path') -and ($_.Name -ne 'Server')} | Select-Object -ExpandProperty Value)
    $SettingsFileExists  = $true

    Export-ModuleMember -Function $Public.Basename
    Export-ModuleMember -Function $Nested.Basename
}

switch ($SettingsFileExists) {
    True    {Export-ModuleMember -Variable Settings, ADProperties}
    False   {Export-ModuleMember -Variable VarbiCheckSettingsFilePath}
    Default {}
}