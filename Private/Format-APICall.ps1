function Format-APICall {

    [CmdletBinding()]

    param (
        # Property to be used
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'GetUser',
            'CreateUser',
            'UpdateUser',
            'EnableUser',
            'DisableUser',
            'ClearUser'
        )]
        [string]
        $Property,

        # Searches DFRespons based on SSO_UID.
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Name'
        )]
        [string]
        $SSO_UID,

        # Id of the user
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Id'
        )]
        [string]
        $Id,

        # Email address of the user
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Email'
        )]
        [string]
        $Email,

        # Switch that retrieves all users in the system.
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'All'
        )]
        [switch]
        $All,

        #
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Id'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Hashtable'
        )]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Name'
        )]
        [System.Collections.Hashtable]
        $InputObject,

        # Server
        [Parameter(
            Mandatory = $false,
            DontShow  = $true
        )]
        [string]
        $Server = $Settings.Server
    )

    begin {

        $RequestParams = switch ($Property) {

            GetUser {
                switch ($All) {
                    True {
                        @{
                            RequestString = "$Server/accounts?include_inactive=true"
                            Method        = "GET"
                        }
                    }
                    False {
                        if ($Id) {
                            @{
                                RequestString = "$Server/accounts/$Id"
                                Method        = "GET"
                            }
                        }
                        elseif ($SSO_UID) {
                            @{
                                RequestString = "$Server/accounts?include_inactive=true&filter[sso_uid]=$SSO_UID"
                                Method        = "GET"
                            }
                        }
                        elseif ($Email) {
                            @{
                                RequestString = "$Server/accounts?include_inactive=true&filter[email]=$Email"
                                Method        = "GET"
                            }
                        }
                    }
                }
            }
            CreateUser {
                @{
                    RequestString = "$Server/accounts"
                    Method        = "POST"
                    Body          = $InputObject
                }
            }
            {($_ -eq "UpdateUser") -or ($_ -eq "EnableUser") -or ($_ -eq "DisableUser") -or ($_ -eq "ClearUser")} {
                switch ($PSCmdlet.ParameterSetName) {
                    Name {
                        @{
                            RequestString = "$Server/accounts/$SSO_UID"
                            Method        = "PATCH"
                            Body          = $InputObject
                        }
                    }
                    Id   {
                        @{
                            RequestString = "$Server/accounts/$Id"
                            Method        = "PATCH"
                            Body          = $InputObject
                        }
                    }
                    Hashtable {
                        @{
                            RequestString = "$Server/accounts/$($InputObject.UserName)"
                            Method        = "PATCH"
                            Body          = $InputObject
                        }
                    }
                }
            }
        }
    }

    process {

    }

    end {
        return $RequestParams
    }
}
# End function.