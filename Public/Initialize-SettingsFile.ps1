function Initialize-SettingsFile {

    <#
    .SYNOPSIS
    Build a settings file and store it on the computer.

    .DESCRIPTION
    This CMDlet will build a CSV file with information on how to connect to your organizations instance of Varbi.
    The ADProperty parameters are there for you to provide your organizations property names. e.g: In organization A, cellWorkphone number can be found in extensionAttribute6  and organization is found under physicalDeliveryOfficeName
    You will also be prompted to select path to 2 different credential files. If you haven't generated these credential files, please refer to the module documentation.
    Lastly you will be prompted to select a folder where the settings file will be stored.

    .PARAMETER Server
    Your organizations API instance of Varbi. e.g: https://api.varbi.com/v1

    .PARAMETER SSO_UID
    What property value in AD you want to refer to as the Varbi UserName

    .PARAMETER GivenName
    What property value in AD you want to refer to as the Varbi Name This parameter defaults to AD property GivenName. It will also work in conjunction with the Surname parameter to build the Varbi name as follows: $GivenName $Surname

    .PARAMETER Surname
    What property value in AD you want to refer to as the Varbi Name This parameter defaults to AD property Surname. It will also work in conjunction with the GivenName parameter to build the Varbi name as follows: $GivenName $Surname

    .PARAMETER Email
    What property value in AD you want to refer to as the Varbi Mail. Defaults to AD property Mail

    .PARAMETER Workphone
    What property value in AD you want to refer to as the Varbi Workphone

    .EXAMPLE
    # In this example we'll use UserPrincipalName as the SSO_UID/Username and exclude Workphone, CellWorkphone, Title and Organization.
    # In this example we assume that GivenName, Surname and Email all points to the default values.
    Initialize-SettingsFile -Server "https://api.varbi.com/v1" -SSO_UID UserPrincipalName

    # This will give you three different prompts. First one you will have to select the folder where the CSV file are to be stored.
    # Second prompt will ask for the encrypted credential file holding you credentials for Basic Authentication
    # Third prompt you select encrypted credential file with the API key.

    .EXAMPLE
    # Here we splat all of the parameters to feed the Varbi system with full user information.
    $SettingParams = @{
        Server         = "https://api.varbi.com/v1"
        SSO_UID = "SSO_UID"
        GivenName      = "GivenName"
        Surname        = "Surname"
        Email          = "Mail"
        Workphone          = "ExtensionAttribute3"
    }
    Initialize-SettingsFile @SettingParams

    # This will give you three different prompts. First one you will have to select the folder where the CSV file are to be stored.
    # Second prompt will ask for the encrypted credential file holding you credentials for Basic Authentication
    # Third prompt you select encrypted credential file with the API key.

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (

        # Server URI
        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        # ADProperty holding information about users's SSO_UID/Username
        [Parameter()]
        [string]
        $SSO_UID = "SSO_UID",

        # ADproperty containing the given name of the user
        [Parameter()]
        [string]
        $GivenName = "GivenName",

        # ADproperty containing the surname of the user
        [Parameter()]
        [string]
        $Surname = "Surname",

        # ADProperty holding information about user's email address
        [Parameter()]
        [string]
        $Email = "Mail",

        # ADProperty holding information on Workphone number
        [Parameter()]
        [string]
        $Workphone
    )

    begin {
        # Creating variable to store everything in.
        $SettingsTable = [PSCustomObject]@{}

        # Creates a open folder dialog for you to pick a location for the CSV file.
        $SettingsFilePath = Get-FilePath -Type Settings
    }

    process {
        # Creates a open file dialog for you to choose the credential file holding basic authentication information
        # $SettingsTable | Add-Member -MemberType NoteProperty -Name "BASecretPath" -Value $(Get-FilePath -Type BASecret | Select-Object -ExpandProperty BASecret)

        # Creates a open file dialog for you to choose the credential file holding your API key.
        $SettingsTable | Add-Member -MemberType NoteProperty -Name "APIKeyPath" -Value $(Get-FilePath -Type APIKey | Select-Object -ExpandProperty APIkey)

        #region Parameter used
        $CmdName = $MyInvocation.InvocationName
        $ParamList = (Get-Command -Name $CmdName).Parameters

        foreach ($Key in $ParamList.Keys) {
            $Value = (Get-Variable $Key -ErrorAction SilentlyContinue).Value
            if ($Value -or $Value -eq 0) {
                $SettingsTable | Add-Member -MemberType NoteProperty -Name $Key -Value $Value
            }
        }
        #endregion Parameter used
    }

    end {
        # Writing the CSV file
        $SettingsTable | ConvertTo-Csv -NoTypeInformation | Set-Content -Path $SettingsFilePath.Settings

        # Writing a checkfile for the module to remember what location the settings file where stored.
        $SettingsFilePath.Settings | Out-File -LiteralPath $VarbiCheckSettingsFilePath

        Write-Output "Settings file saved to $($SettingsFilePath.Settings):"
        $SettingsTable

        Write-Warning -Message "You must reload the module for the changes to take effect and use the -Force parameter."
    }
}
# End function.