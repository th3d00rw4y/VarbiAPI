function ConvertFrom-ADObject {

    [CmdletBinding()]

    param (
        # ADObject input
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $ADObject,

        # Return type
        [Parameter()]
        [ValidateSet(
            'HashTable',
            'PSCustomObject'
        )]
        [string]
        $ReturnType = 'HashTable'
    )

    begin {
        $UsedParameters = New-Object -TypeName PSCustomObject -Property @{
            lastname  = ""
            firstname = ""
            sso_uid   = ""
            email     = ""
            workphone = ""
            metadata  = @(
                @{"key"="date_changed"; "value"=$(Get-Date -Format s)}
                @{"key"="creation_type"; "value"="VarbiAPI"}
            )
        }
    }

    process {

        foreach ($item in $Settings.PSObject.Properties | Where-Object {($_.Name -notlike '*Path') -and ($_.Name -ne 'Server')}) {
            switch ($item) {
                {$_.Name -eq "SSO_UID"}   {[string]$UsedParameters.sso_uid = $ADObject | Select-Object -ExpandProperty $item.Value}
                {$_.Name -eq "GivenName"} {[string]$UsedParameters.firstname = $ADObject | Select-Object -ExpandProperty $item.Value}
                {$_.Name -eq "Surname"}   {[string]$UsedParameters.lastname = $ADObject | Select-Object -ExpandProperty $item.Value}
                {$_.Name -eq "Email"}     {[string]$UsedParameters.email = $ADObject | Select-Object -ExpandProperty $item.Value}
                {$_.Name -eq "Workphone"} {[string]$UsedParameters.workphone = $ADObject | Select-Object -ExpandProperty $item.Value}
            }
        }

        switch ($ReturnType) {
            HashTable      {
                $ReturnObject = @{}
                $UsedParameters.psobject.Properties | ForEach-Object {$ReturnObject[$_.Name] = $_.Value}
            }
            PSCustomObject {
                $ReturnObject = $UsedParameters
            }
        }
    }

    end {
        return $ReturnObject
    }
}