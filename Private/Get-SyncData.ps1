function Get-SyncData {

    [CmdletBinding()]

    param (
        # Source object (All varbi users)
        [Parameter(Mandatory = $true)]
        [System.Object]
        $CurrentVarbiUsers,

        # Input object to be processed
        [Parameter(Mandatory = $true)]
        [System.Object]
        $InputObject,

        # List of excluded accounts
        [Parameter(Mandatory = $true)]
        [string[]]
        $ExcludedAccounts
    )

    begin {
        $SyncChanges = New-Object -TypeName PSCustomObject -Property ([ordered]@{
            Updates       = [PSCustomObject]@{}
            StatusChanges = [PSCustomObject]@{}
        })
    }

    process {

        $SyncChanges.Updates = foreach ($ADObject in $InputObject) {
            $VarbiObject = $CurrentVarbiUsers | Where-Object {$_.email -eq $ADObject.email}

            if ($VarbiObject) {
                # Compare user
                try {
                    $Compare = Compare-Object -ReferenceObject $ADObject -DifferenceObject $VarbiObject -Compact -ErrorAction SilentlyContinue

                    if ($Compare) {
                        $TempHash = [PSCustomObject][ordered]@{}
            
                        # Identifying what properties that differ
                        foreach ($Found in $Compare) {
                            switch ($Found.Property) {
                                email        {$TempHash | Add-Member -MemberType NoteProperty -Name 'email' -Value $Found.ReferenceValue}
                                firstname    {$TempHash | Add-Member -MemberType NoteProperty -Name 'firstname' -Value $Found.ReferenceValue}
                                lastname     {$TempHash | Add-Member -MemberType NoteProperty -Name 'lastname' -Value $Found.ReferenceValue}
                                workphone    {$TempHash | Add-Member -MemberType NoteProperty -Name 'workphone' -Value $Found.ReferenceValue}
                                sso_uid      {$TempHash | Add-Member -MemberType NoteProperty -Name 'sso_uid' -Value $Found.ReferenceValue}
                            }
                        }
        
                        if ($TempHash | get-member | Where-Object {$_.MemberType -contains 'NoteProperty'}) {
        
                            foreach ($Property in ($TempHash | get-member | Where-Object {$_.MemberType -contains 'NoteProperty'})) {
                                if (-not ($TempHash.$($Property.Name).Length -gt 0)) {
                                    $TempHash.$($Property.Name) = ""
                                }
                            }
        
                            $TempHash | Add-Member -MemberType NoteProperty -Name 'id' -Value $VarbiObject.id
                            # $TempHash | Add-Member -MemberType NoteProperty -Name 'action' -Value 'Update'
        
                            # $UpdateParams = @{}
                            # $TempHash.psobject.Properties | ForEach-Object {$UpdateParams[$_.Name] = $_.Value}
        
                            # $UpdateParams
                            # ! Logga här!!
                            # Update-VarbiUser @UpdateParams
        
                            $TempHash
                            Clear-Variable Compare, TempHash, VarbiObject
                        }
                    }
                }
                catch {
                    Write-Error $_.Exception.Message
                }
            }
        }

        $SyncChanges.StatusChanges = try {
            $UserCompare = Compare-Object -ReferenceObject $CurrentVarbiUsers.email -DifferenceObject $ADUsersFormatted.email -IncludeEqual -ErrorAction SilentlyContinue | Where-Object {$_.InputObject -notin $ExcludedAccounts}

            if ($UserCompare) {

                foreach ($ComparedUser in $UserCompare) {
    
                    $CompareUserObject = $CurrentVarbiUsers | Where-Object {$_.email -eq $ComparedUser.InputObject}
    
                    if ((-not ((Get-ADUser -Filter "mail -eq '$($ComparedUser.InputObject)'").Enabled) -eq $true) -and ($CompareUserObject.status -eq $true)) {
                        
                        [PSCustomObject]@{
                            action = "Update"
                            status = $false
                            email  = $ComparedUser.InputObject
                        }
    
                    }
                    else {
                        switch ($ComparedUser) {
                            # If '=>' a new user will be created
                            {$_.SideIndicator -eq '=>'} {
                                
                                if ((Get-ADUser -Filter "mail -eq '$($ComparedUser.InputObject)'").Enabled -eq $true) {
                                    [PSCustomObject]@{
                                        action = "New"
                                        status = $true
                                        email  = $ComparedUser.InputObject
                                    }
                                }
                            }
    
                            # If '<=', user has been removed from AD group and will therefore be disabled in Varbi.
                            {$_.SideIndicator -eq '<='} {
                                if (($CurrentVarbiUsers | Where-Object {$_.email -eq $ComparedUser.InputObject}).status -eq $true) {
                                    
                                    [PSCustomObject]@{
                                        action = "Update"
                                        status = $false
                                        email  = $ComparedUser.InputObject
                                    }
                                }
                            }
    
                            # If '==' and user is set to Disabled within Varbi, the user will be reenabled.
                            {$_.SideIndicator -eq '=='} {
                                if (($CurrentVarbiUsers | Where-Object {$_.email -eq $ComparedUser.InputObject}).status -eq $false) {
                                    
                                    [PSCustomObject]@{
                                        action = "Update"
                                        status = $true
                                        email  = $ComparedUser.InputObject
                                    }
                                }
                            }
                        }
                    }
    
                    Clear-Variable CompareUserObject
                }
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }

    end {
        return $SyncChanges
    }
}