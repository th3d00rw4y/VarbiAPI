function New-VarbiUser {

    <#
    .SYNOPSIS
    Create a new user in Varbi

    .DESCRIPTION
    This CMDlet will let you create a new user in Varbi. Works with either providing data manually to parameter set ManualSet or by piping an ADObject to the CMDlet.

    .PARAMETER Surname
    Lastname of the user to be created - Mandatory!

    .PARAMETER GivenName
    Firstname of the user to be created - Mandatory!

    .PARAMETER SamAccountName
    SamAccountName/Username of the user to be created - Mandatory!

    .PARAMETER Email
    Email of the user to be created - Mandatory!

    .PARAMETER Title
    Title of the user to be created

    .PARAMETER Cellphone
    Cellphone number of the user to be created

    .PARAMETER ADObject
    ADObject of a user to be created. Must include GivenName, Surname, Mail/UserPrincipalName

    .PARAMETER OnlySamAccountName
    Create user object in Varbi based only on the SamAccountName of an AD user.
    Using this parameter will leverage the ActiveDirectory module and fetch information on the user from your AD.
    Can be used in conjunction with the ADProperties parameter.

    .EXAMPLE
    # In this example we manually build our user object and then create the user based on the parameters used.
    # Note that all four parameters are mandatory.
    $VarbiUserParams = @{
        Surname         = "Dailor"
        GivenName       = "Brann"
        SamAccountName  = "BRADAI01"
        Email           = "brann.dailor@greatmusicians.com"

    }
    New-VarbiUser @VarbiUserParams
    Example response:
    {
        id           : 17
        name         : Brann Dailor
        username     : BRANDAI01
        email        : brann.dailor@greatmusicians.com
        disabled     : False
    }

    .EXAMPLE
    # This example will create the user in Varbi based only on a SamAccountName from the active directory along with provided properties
    New-VarbiUser -OnlySamAccountName BRADAI01
    Example response:
    {
        id           : 17
        name         : Brann Dailor
        username     : BRANDAI01
        email        : brann.dailor@greatmusicians.com
        title        : Drummer/Singer
        organization : Mastodon
        phone        : 09087
        cellphone    : 0986785423
        disabled     : False
    }

    .EXAMPLE
    In this example will will get a user from the AD and pipe it to the CMDlet for creating a new Varbi user.
    Get-ADUser -Identity BRANDAI01 | New-VarbiUser
    Example response:
    {
        id           : 17
        name         : Brann Dailor
        username     : BRANDAI01
        email        : brann.dailor@greatmusicians.com
        disabled     : False
    }

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]

    param (
        # Surname of the user
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'ManualSet'
        )]
        [string]
        $Surname,

        # Given name of the user
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'ManualSet'
        )]
        [string]
        $GivenName,

        # SamAccountName for the user
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'ManualSet'
        )]
        [string]
        $SSO_UID,

        # The user's mail
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'ManualSet'
        )]
        [string]
        $Email,

        # The user's workphone number
        [Parameter(
            Mandatory                       = $false,
            ParameterSetName                = 'ManualSet'
        )]
        [string]
        $Workphone,

        # Object containing all properties required for user creation.
        [Parameter(
            Mandatory         = $true,
            ParameterSetName  = 'ObjectSet',
            ValueFromPipeline = $true
        )]
        [Microsoft.ActiveDirectory.Management.ADAccount]
        $ADObject,

        # Create user based only on AD samaccountname property in conjunction with AD properties provided in the settings file.
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'OnlySamAccountName'
        )]
        [ValidateScript({Get-ADUser $_})]
        [string]
        $OnlySamAccountName
    )

    begin {
        $Parameters = $MyInvocation.BoundParameters.Keys
    }

    process {

        #region Formatting the payload
        $UsedParameters = switch ($PSCmdlet.ParameterSetName) {

            ManualSet {
                Format-UsedParameter -SetName ManualSet -InputObject $Parameters
            }
            ObjectSet {
                ConvertFrom-ADObject -ADObject $ADObject
            }
            OnlySamAccountName {
                $ADObject = Get-ADUser -Identity $OnlySamAccountName -Properties $ADProperties
                ConvertFrom-ADObject -ADObject $ADObject
            }
        }
        #endregion Formatting the payload

        # Getting the request call parameters
        $RequestParams = Format-APICall -Property CreateUser -InputObject $UsedParameters

        # Splatting the parameters for the request
        $InvokeParams = @{
            RequestString = $RequestParams.RequestString
            Method        = $RequestParams.Method
            Body          = $RequestParams.Body
        }

        # Sending the payload to Invoke-VarbiAPI
        try {
            $Response = Invoke-VarbiAPI @InvokeParams -ErrorAction Stop
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }

    end {
        return $Response
        # return $InvokeParams
    }
}
# End function.