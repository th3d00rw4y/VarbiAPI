function Enable-VarbiUser {

    <#
    .SYNOPSIS
    Enable a user in Varbi

    .DESCRIPTION
    This CMDlet will enable a user in the Varbi system based on that the user already exists and is in a disabled state.

    .PARAMETER Id
    Disable the user based on it's Id.

    .PARAMETER SamAccountName
    Disable the user based on it's SamAccountName/Username

    .EXAMPLE
    Enable-VarbiUser -SamAccountName DEAFER01
    Example response:
    {
        id           : 10
        name         : Dean Fertita
        username     : DEAFER01
        title        : Multi instrumentalist
        email        : dean.fertita@greatmusicians.com
        organization : Queens of the Stoneage
        disabled     : False
    }

    .EXAMPLE
    Enable-VarbiUser -Id 14
    Example response:
    {
        id           : 14
        name         : Michael Schuman
        username     : MICSCH01
        title        : Basist/Singer
        email        : michael.schuman@greatmusicians.com
        organization : Queens of the Stoneage...
        disabled     : False
    }

    .EXAMPLE
    Get-ADUser -Identity BREHIN01 | Enable-VarbiUser
    This example will fetch an AD account and pipe it to Enable-VarbiUser
    Example response:
    {
        id           : 11
        name         : Brent Hinds
        username     : BREHIN01
        title        : Guitarist/Singer
        email        : brent.hinds@greatmusicians.com
        organization : Mastodon
        disabled     : False
    }

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (
        # Id of the user that will be enabled
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'Id',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Id,

        # Email of the user that will be disabled
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Email',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Email,

        # SamAccountName of the user to be enabled
        [Parameter(
            Mandatory                       = $true,
            ParameterSetName                = 'SamAccountName',
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $SSO_UID
    )

    begin {
        $Body = [ordered]@{
            status = $true
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            Id {
                $RequestParams = Format-APICall -Property EnableUser -Id $Id -InputObject $Body
            }
            Email {
                $Id = Get-VarbiUser -Email $Email | Select-Object -ExpandProperty id
                $RequestParams = Format-APICall -Property DisableUser -Id $Id -InputObject $Body
            }
            SamAccountName {
                $Id = Get-VarbiUser -SSO_UID $SSO_UID | Select-Object -ExpandProperty id
                $RequestParams = Format-APICall -Property DisableUser -Id $Id -InputObject $Body
            }
        }

        $InvokeParams = @{
            RequestString = $RequestParams.RequestString
            Method        = $RequestParams.Method
            Body          = $RequestParams.Body
        }

        $Response = Invoke-VarbiAPI @InvokeParams
    }

    end {
        # return $InvokeParams
        return $Response
    }
}