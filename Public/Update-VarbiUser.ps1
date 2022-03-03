function Update-VarbiUser {
    <#
    .SYNOPSIS
    Updates a Varbi user

    .DESCRIPTION
    This CMDlet will let you update a user within Varbi.

    .PARAMETER SamAccountName
    SamAccountName/Username of the user to be updated

    .PARAMETER Id
    Id of the user to be updated

    .PARAMETER EMail
    Updates the email for a user

    .PARAMETER Title
    Updates the title of a user

    .PARAMETER Phone
    Updates the phone number of a user

    .PARAMETER CellPhone
    Updates the cellphone number of a user

    .PARAMETER Organization
    Updates the organization of a user

    .PARAMETER ADObject
    AD object of a user. Each of the properties in the AD object that match what you set as property identifiers in your settings file will be updated

    .PARAMETER OnlySamAccountName
    Update a user based on the users AD SamAccountName. Will utilize the property identifiers that you set in your settings file and update the user in Varbi

    .EXAMPLE
    # This example will update a user in Varbi with the following properties: title, cellphone and organization
    Update-VarbiUser -SamAccountName BREHIN01 -Title "Singer/Guitarist" -CellPhone "098765453421" -Organization "Mastodon"
    Example response:
    {
        id           : 11
        name         : Brent Hinds
        username     : BREHIN01
        title        : Guitarist/Singer
        email        : brent.hinds@greatmusicians.com
        cellphone    : 098765453421
        organization : Mastodon
    }

    .EXAMPLE
    # This example will update a user in Varbi based only on the SamAccountName
    Update-VarbiUser -OnlySamAccountName BREHIN01
    # Again, AD properties are determined by what you provided to your settings file when running Initialize-SettingsFile
    Example response:
    {
        id           : 11
        name         : Brent Hinds
        username     : BREHIN01
        title        : Guitarist/Singer
        email        : brent.hinds@greatmusicians.com
        cellphone    : 098765453421
        organization : Mastodon
    }

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]

    param (

        # Id of the user
        [Parameter(
            Mandatory        = $true,
            ParameterSetName = 'ManualSet',
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(
            Mandatory        = $true,
            ParameterSetName = 'ObjectSet',
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(
            Mandatory        = $true,
            ParameterSetName = 'OnlySamAccountName',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $id,

        # Given name of the user
        [Parameter(
            Mandatory        = $false,
            ParameterSetName = 'ManualSet'
        )]
        [string]
        $Firstname,

        # Surname of the user
        [Parameter(
            Mandatory        = $false,
            ParameterSetName = 'ManualSet'
        )]
        [string]
        $Lastname,

        # SamAccountName for the user
        [Parameter(
            Mandatory        = $false,
            ParameterSetName = 'ManualSet'
        )]
        [ValidateScript({Get-ADUser -Filter "UserPrincipalName -eq '$_'"})]
        [string]
        $SSO_UID,

        [Parameter(
            Mandatory        = $false,
            ParameterSetName = 'ManualSet'
        )]
        [string]
        $EMail,

        # Phone number for the user
        [Parameter(
            Mandatory                       = $false,
            ParameterSetName                = 'ManualSet',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Workphone,

        # Object containing all properties required for user creation.
        [Parameter(
            Mandatory         = $true,
            ParameterSetName  = 'ObjectSet',
            ValueFromPipeline = $true
        )]
        [ValidateScript({Get-ADUser $_.SamAccountName})]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $ADObject,

        # Update user based only on AD samaccountname property
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'OnlySamAccountName'
        )]
        [ValidateScript({Get-ADUser $_})]
        [string]
        $OnlySamAccountName
    )

    begin {

        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)

        $Parameters = $MyInvocation.BoundParameters.Keys | Where-Object {$_ -ne 'Whatif'}
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {

            ManualSet {
                $UsedParameters = Format-UsedParameter -SetName ManualSet -InputObject $Parameters
            }
            ObjectSet {
                $UsedParameters = ConvertFrom-ADObject -ADObject $ADObject
            }
            OnlySamAccountName {
                $ADObject = Get-ADUser -Identity $OnlySamAccountName -Properties $ADProperties
                $UsedParameters = ConvertFrom-ADObject -ADObject $ADObject
            }
        }

        $RequestParams = Format-APICall -Property UpdateUser -InputObject $UsedParameters -Id $Id

        $InvokeParams = @{
            RequestString = $RequestParams.RequestString
            Method        = $RequestParams.Method
            Body          = $RequestParams.Body
        }

        if ($PSCmdlet.ShouldProcess("$($InvokeParams.Body.sso_uid)")) {
            $Response = Invoke-VarbiAPI @InvokeParams
        }
    }

    end {
        return $Response
        # return $InvokeParams
    }
}