function Format-UsedParameter {

    [CmdletBinding()]

    param (

        # What parameter set that has been used.
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'ManualSet',
            'ObjectSet',
            'OnlySamAccountName'
        )]
        [string]
        $SetName,

        # Inputobject containing the $PSCmdlet
        [Parameter(Mandatory = $true)]
        [System.Object]
        $InputObject
    )

    begin {
        # $UsedParameters = New-Object -TypeName PSCustomObject
        $UsedParameters = [PSCustomObject][ordered]@{}
        
        $MetaData = @(
            @{"key"="date_changed"; "value"=$(Get-Date -Format s)}
            @{"key"="creation_type"; "value"="VarbiAPI"}
        )
    }

    process {

        switch ($SetName) {
            ManualSet {

                $TMPHash = foreach ($key in $InputObject) {
                    $value = (get-variable $key).Value
                    @{
                        "$key" = "$value"
                    }
                }

                foreach ($item in $TMPHash) {
                    switch ($item.Keys) {
                        Surname        {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'lastname' -Value $item.Surname}
                        GivenName      {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'firstname' -Value $item.GivenName}
                        SSO_UID        {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'sso_uid' -Value $item.SSO_UID}
                        EMail          {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'email' -Value $item.Email}
                        Workphone      {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'workphone' -Value $item.Workphone}
                    }
                }
            }
            {($_ -eq 'ObjectSet') -or ($_ -eq 'OnlySamAccountName')} {

                switch ($InputObject.PropertyNames) {
                    Surname        {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'lastname' -Value $item.Surname}
                    GivenName      {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'firstname' -Value $item.GivenName}
                    SSO_UID        {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'sso_uid' -Value $item.SSO_UID}
                    EMail          {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'email' -Value $item.Email}
                    Workphone      {$UsedParameters | Add-Member -MemberType NoteProperty -Name 'workphone' -Value $item.Workphone}
                }
            }
        }

        $Body = @{}
        $UsedParameters.psobject.Properties | ForEach-Object {$Body[$_.Name] = $_.Value}
        $Body | Add-Member -MemberType NoteProperty -Name "metadata" -Value $MetaData
    }

    end {
        return $Body
    }
}
# End function.