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
        $ADGroup = "ACCESS-ADM-Varbi",

        # Path to file holding accounts you want to exclude from the synchronization. Exclusion is based on Username in Varbi.
        [Parameter()]
        [string]
        $PathToExcludedAccountsFile = "C:\TMP\Secrets\VarbiExcludedAccounts.txt",

        # Log file path
        [Parameter()]
        [string]
        $LogFilePath = "C:\TMP\VarbiLog.log"
    )

    begin {

        $Component = $MyInvocation.MyCommand
        Write-StartEndLog -Action Start -LogFilePath $LogFilePath

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
                $ADGroupMembers = Get-ADGroupMember -Identity $ADGroup -Recursive

                # Formatting each AD user to match with object structure in Varbi.
                $ADUsersFormatted = foreach ($GroupMember in $ADGroupMembers) {
                    Get-ADUser -Identity $GroupMember.SamAccountName -Properties $ADProperties | ConvertFrom-ADObject -ReturnType PSCustomObject
                }

                # Comparing AD group members with current Varbi users to see if there are any changes to be made.
                $UsersToUpdate = Get-SyncData -CurrentVarbiUsers $CurrentVarbiUsers -InputObject $ADUsersFormatted -ExcludedAccounts $ExcludedAccounts

                switch ($UsersToUpdate) {
                    
                    {$_.StatusChanges} {
                        foreach ($Change in $_.StatusChanges) {
                            switch ($Change.action) {
                                Update {
                                    switch ($Change.status) {
                                        True  {
                                            Enable-VarbiUser -Email $Change.email
                                            # $ReturnHash.Enabled = $Change.email
                                            Write-CMTLog -Message "User with email: $($Change.email) has been enabled" -LogLevel Normal -Component $Component -LogFilePath $LogFilePath
                                        }
                                        False {
                                            Disable-VarbiUser -Email $Change.email
                                            Clear-VarbiUser -Email $Change.email
                                            # $ReturnHash.Disabled = $Change.email
                                            Write-CMTLog -Message "User with email: $($Change.email) has been disabled and user properties cleared." -LogLevel Normal -Component $Component -LogFilePath $LogFilePath
                                        }
                                    }
                                }
                                New {
                                    $NewVarbiUser = Get-ADUser -Filter "mail -eq '$($Change.email)'" -Properties $ADProperties | New-VarbiUser
                                    Write-CMTLog -Message "User created: id = $($NewVarbiUser.id) - sso_uid = $($NewVarbiUser.sso_uid)" -LogLevel Normal -Component $Component -LogFilePath $LogFilePath
                                    Clear-Variable NewVarbiUser
                                }
                            }
                        }
                    }
                    {$_.Updates} {

                        foreach ($item in $_.Updates) {

                            if ((Get-VarbiUser -Id $item.id).status -eq $true) {
                                
                                $UpdateParams = @{}
                                $item.psobject.Properties | ForEach-Object {$UpdateParams[$_.Name] = $_.Value}
                                Write-Host "Hoppp!" -ForegroundColor Red
                                Update-VarbiUser @UpdateParams
                                # $ReturnHash.Updates = $item.id

                                foreach ($Property in $item.psobject.Properties | Where-Object {$_.Name -ne 'id'}) {
                                    Write-CMTLog -Message "User id: $($item.id) has been updated with $($Property.Name) = $($Property.Value)" -LogLevel Normal -Component $Component -LogFilePath $LogFilePath
                                }
                            }
                        }
                    }
                }
            }
            False {}
        }
    }

    end {
        Write-StartEndLog -Action Stop -LogFilePath $LogFilePath
    }
}
# End function.