function Sync-VarbiFromADGroup {
    <#
    .SYNOPSIS
    Synchronize Varbi from an AD group.

    .DESCRIPTION
    This CMDlet will synchronize the Varbi system with an AD group. It will check each value provided in $ADProperties and update values that differ.

    .PARAMETER ADGroup
    CN of the AD group

    .PARAMETER PathToExcludedAccountsFile
    Path to file containing accounts that will be excluded from the synchronization.

    .EXAMPLE
    Sync-VarbiFromADGroup -ADGroup 'ACCESS-Varbi' -PathToExcludedAccountsFile "C:\Scripts\Varbi_ExcludedAccounts.txt"

    .NOTES
    Author: Simon Mellergård | IT-avdelningen, Värnamo kommun
    #>
    [CmdletBinding()]

    param (
        # Name of AD group to be synced with
        [Parameter(Mandatory = $true)]
        [string]
        $ADGroup,

        # Path to file holding accounts you want to exclude from the synchronization. Exclusion is based on Username in Varbi.
        [Parameter()]
        [string]
        $PathToExcludedAccountsFile = "C:\TMP\Secrets\VarbiExcludedAccounts.txt"
    )

    begin {

        # Checking that provided ADGroup actually exists.
        $ADGroupExists = try {
            if (Get-ADGroup -Identity $ADGroup -ErrorAction Stop) {
                $true
            }
        }
        catch {
            $false
        }

        # Getting all current users in Varbi
        $CurrentVarbiUsers = Get-VarbiUser -All

        # Getting all accounts that are to be excluded from the synchronization.
        $ExcludedAccounts = Get-Content -Path $PathToExcludedAccountsFile
    }

    process {

        switch ($ADGroupExists) {
            True  {

                # Retreiving all users that are member of provided group.
                $ADGroupMembers = Get-ADGroupMember -Identity $ADGroup

                # Formatting each AD user to match with object structure in Varbi.
                $ADUsersFormatted = foreach ($GroupMember in $ADGroupMembers) {
                    Get-ADUser -Identity $GroupMember.SamAccountName -Properties $ADProperties | ConvertFrom-ADObject -ReturnType PSCustomObject
                }

                # Comparing AD group members with current Varbi users to see if there are any changes to be made.
                $UsersToUpdate = foreach ($item in $ADUsersFormatted) {

                    $TMP = $CurrentVarbiUsers | Where-Object {$_.email -eq $item.email}

                    # Compare user
                    try {
                        $Compare = Compare-Object -ReferenceObject $item -DifferenceObject $TMP -Compact -ErrorAction SilentlyContinue
                    }
                    catch {
                        Write-Error $_.Exception.Message
                    }

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

                            $TempHash | Add-Member -MemberType NoteProperty -Name 'id' -Value $TMP.id

                            $UpdateParams = @{}
                            $TempHash.psobject.Properties | ForEach-Object {$UpdateParams[$_.Name] = $_.Value}

                            $UpdateParams
                            # ! Logga här!!
                            Update-VarbiUser @UpdateParams

                            Clear-Variable UpdateParams
                        }

                        Clear-Variable Compare, TempHash, TMP
                    }
                }

                # Comparing AD users with Varbi users to see if any accounts are to be enabled/disabled
                try {
                    $UserCompare = Compare-Object -ReferenceObject $CurrentVarbiUsers.email -DifferenceObject $ADUsersFormatted.email -IncludeEqual -ErrorAction SilentlyContinue | Where-Object {$_.InputObject -notin $ExcludedAccounts}
                }
                catch {
                    Write-Error $_.Exception.Message
                }

                if ($UserCompare) {

                    $UserChanges = foreach ($ComparedUser in $UserCompare) {
                        switch ($ComparedUser) {
                            # If '=>' a new user will be created
                            {$_.SideIndicator -eq '=>'} {Get-ADUser -Identity $ComparedUser.InputObject -Properties $ADProperties}# | New-VarbiUser}

                            # If '<=', user has been removed from AD group and will therefore be disabled in Varbi.
                            {$_.SideIndicator -eq '<='} {
                                if (($CurrentVarbiUsers | Where-Object {$_.email -eq $ComparedUser.InputObject}).status -eq $true) {
                                    Disable-VarbiUser -Email $ComparedUser.InputObject
                                    Write-Host "Disable: $($ComparedUser.InputObject)" -ForegroundColor Red
                                }
                            }

                            # If '==' and user is set to Disabled within Varbi, the user will be reenabled.
                            {$_.SideIndicator -eq '=='} {
                                if (($CurrentVarbiUsers | Where-Object {$_.email -eq $ComparedUser.InputObject}).status -eq $false) {
                                    Enable-VarbiUser -Email $ComparedUser.InputObject
                                    Write-Host "Enable!" -ForegroundColor Green
                                }
                            }
                        }
                    }
                }
            }
            False {}
        }

        $ReturnHash = @()
        $ReturnHash += $UsersToUpdate
        $ReturnHash += $UserChanges
    }

    end {
        return $ReturnHash
    }
}
# End function.