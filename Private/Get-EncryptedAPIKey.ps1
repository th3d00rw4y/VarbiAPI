function Get-EncryptedAPIKey {

    [CmdletBinding()]

    param (
        # Path to the encrypted API key.
        [Parameter(Mandatory = $false)]
        [string]
        $LiteralPath = $Settings.APIKeyPath
    )
    
    begin {
        $APIKey = Get-Secret -LiteralPath $LiteralPath
    }
    
    process {
        $Headers = @{
            "X-Api-key" = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($APIKey))
        }
    }
    
    end {
        return $Headers
    }
}