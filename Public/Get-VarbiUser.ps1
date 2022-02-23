function Get-VarbiUser {

    <#
    .SYNOPSIS
    Get user(s) from the Varbi database.

    .DESCRIPTION
    Retreives a user based on it's username or id. Can also be called with the -All switch to retrieve all users. PageSize can be used in conjunction with the -All switch to limit number of objects returned.

    .PARAMETER SSO_UID
    Get user object based on SSO_UID/username.

    .PARAMETER Id
    Get user object based on id.

    .PARAMETER All
    Retrieves all user objects

    .PARAMETER PageSize
    Sets the maximum number of user objects to be returned.

    .EXAMPLE
    Get-VarbiUser -SSO_UID JIMPAG01
    Example respone:
    {
        id           : 45
        name         : Jimmy Page
        username     : JIMPAG01
        title        : Guitarist
        email        : jimmy.page@greatguitarists.com
        organization : Led Zeppelin
        phone        : 12345
        cellPhone    : 1234567890
        disabled     : False
    }

    .Example
    # This example fetches an user from the active directory and pipes the AD object into the Get-VarbiUser
    Get-ADUser JOSHOM01 | Get-VarbiUser
    Example respone:
    {
        id           : 01
        name         : Joshua Homme
        username     : JOSHOM01
        title        : Singer/Guitarist
        email        : joshua.homme@greatguitarists.com
        organization : Queens of the Stoneage
        phone        : 54321
        cellPhone    : 0987654321
        disabled     : True
    }

    .EXAMPLE
    Get-VarbiUser -Id 02
    Example respons:
    {
        id           : 02
        name         : Troy Van Leeuwen
        username     : TROLEE01
        title        : multi instrumentalist
        email        : troy.van.leeuwen@greatguitarists.com
        organization : Queens of the Stoneage
        disabled     : True
    }

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>

    [CmdletBinding()]

    param (
        # Searches Varbi based on SSO_UID.
        [Parameter(
            Position  = 0,
            Mandatory = $true,
            ParameterSetName = 'Name',
            ValueFromPipelineByPropertyName = $true
        )]
        #[ValidateScript({Get-ADUser $_})]
        [string]
        $SSO_UID,

        # Searches Varbi based on Id
        [Parameter(
            Position  = 1,
            Mandatory = $true,
            ParameterSetName = 'Id'
        )]
        [string]
        $Id,

        # Searches Varbi based on Email address
        [Parameter(
            Position  = 2,
            Mandatory = $true,
            ParameterSetName = 'Email'
        )]
        [string]
        $Email,

        # Switch that retrieves all users in the system.
        [Parameter(
            Position  = 3,
            Mandatory = $true,
            ParameterSetName = 'All'
        )]
        [switch]
        $All
    )

    begin {

    }

    process {

        # Switch that identifies what parameter that has been used and sends the parameter data to the Format-APICall cmdlet.
        # The object returned will contain an object with invoke uri and method for the request.
        $RequestProperties = switch ($PSCmdlet.ParameterSetName) {
            Name  {Format-APICall -Property GetUser -SSO_UID $SSO_UID}
            Id    {Format-APICall -Property GetUser -Id $Id}
            Email {Format-APICall -Property GetUser -Email $Email}
            All   {Format-APICall -Property GetUser -All}
        }

        # Passing the invoke parameters to the Invoke-VarbiAPI cmdlet.
        $Response = Invoke-VarbiAPI @RequestProperties
    }

    end {
        # Returning what comes from the Invoke-VarbiAPI cmdlet.
        return $Response
    }
}