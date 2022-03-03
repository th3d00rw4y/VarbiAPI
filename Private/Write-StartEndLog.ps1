function Write-StartEndLog {

    [CmdletBinding()]

    param (
        # Decides whether to return start of log entry or end of log entry.
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet(
            'Start',
            'Stop'
        )]
        [string]
        $Action,

        # Log file path
        [Parameter(Mandatory = $true)]
        [string]
        $LogFilePath
    )
    begin {
        $Component = $MyInvocation.MyCommand
    }

    process {
        
        switch ($Action) {
            'Start' {
                Write-CMTLog -Message "==================================> Script run started $(Get-Date) <==================================" -Component $Component -LogLevel Normal -LogFilePath $LogFilePath
            }
            'Stop' {
                Write-CMTLog -Message "==================================> Script run stopped $(Get-Date) <==================================" -Component $Component -LogLevel Normal -LogFilePath $LogFilePath
            }
        }
    }

    end {}
}