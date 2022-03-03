function Clear-VarbiUser {

    <#
    .SYNOPSIS
    Clears all properties on a user in Varbi.

    .DESCRIPTION
    This CMDet will send a PATCH request to the API clearing the user's properties provided with either Id or SamAccountName.

    .PARAMETER Id
    Id of the user to be disabled. Entering an id that does not exist in the system will return an error code.

    .PARAMETER SamAccountName
    SamAccountname/Username of the user to be disabled. Entering an value that does not exist in the system will return an error code.

    .EXAMPLE
    # This example will disable a user in Varbi based on the id.
    Disable-VarbiUser -Id 23

    Example response:
    {
        id           : 23
        name         : Alain Johannes
        username     : ALAJOH01
        title        : Multi instrumentalist
        email        : alain.johannes@greatmusicians.com
        organization : Them Crooked Vultures, Queens of the Stone Age...
        disabled     : True
    }

    .EXAMPLE
    # This example will take an user object retreived from AD, contaning the property SamAccountName and pipe it to the Disable-VarbiUser CMDlet.
    $ADObject | Disable-VarbiUser

    Example response:
    {
        id           : 34
        name         : Jon Theodore
        username     : JONTHE01
        title        : Drummer
        email        : jon.theodore@greatmusicians.com
        organization : The Mars Volta, Queens of the Stone Age
        disabled     : True
    }

    .EXAMPLE
    # This example will disable a user in Varbi based on the username.
    Disable-VarbiUser -SamAccountName DAVGRO01

    Example response:
    {
        id           : 04
        name         : Dave Grohl
        username     : DAVGRO01
        title        : Drummer/Singer/Guitarist
        email        : dave.grohl@greatmusicians.com
        organization : Them Crooked Vultures, Foo Fighters
        disabled     : True
    }

    .EXAMPLE
    # Here we create an array that contains a number of user Id's
    $Array = @(
        '45',
        '67',
        '90'
    )

    # The array is piped into a foreach loop that will iterate and disable each user connected to the Id's

    $Array | Foreach-Object {Disable-VarbiUser -Id $_}

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (
        # Id of the user that will be disabled
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

        # SamAccountName of the user to be disabled
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
            sso_uid   = ""
            workphone = ""
            metadata  = @(
                @{"key"="date_changed"; "value"=$(Get-Date -Format s)}
                @{"key"="creation_type"; "value"="VarbiAPI"}
            )
        }
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            Id {
                $RequestParams = Format-APICall -Property ClearUser -Id $Id -InputObject $Body
            }
            Email {
                $Id = Get-VarbiUser -Email $Email | Select-Object -ExpandProperty id
                $RequestParams = Format-APICall -Property ClearUser -Id $Id -InputObject $Body
            }
            SamAccountName {
                $Id = Get-VarbiUser -SSO_UID $SSO_UID | Select-Object -ExpandProperty id
                $RequestParams = Format-APICall -Property ClearUser -Id $Id -InputObject $Body
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
        return $Response
        # return $InvokeParams
    }
}