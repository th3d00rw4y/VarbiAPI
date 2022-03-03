function Write-CMTLog {
    <#
    .SYNOPSIS
        A helper function for writing logfiles with the CMTrace format.

    .DESCRIPTION
        This function will write everything specified into a centeralized log file per month. Using CMTrace format.

    .PARAMETER Message
        In double quotes, writes the text to a logfile.

    .PARAMETER LogLevel
        Sets the level of logging. Accepted values are Normal, Warning, Error. Normal being the default value

    .PARAMETER Component
        In the various functions of Update-NilexInventory.psm1 the $Component variable is defined inside each function and contains COMPUTERNAME\FUNCTIONNAME:ROW
        Example: AWVKAPP01\Get-ComputersFromAD:643

    .EXAMPLE
        Write-CMTLog -Message "Log text here" -Component $Component
        This example will write a log entry with the text "Log text here".

    .EXAMPLE
        Write-CMTLog -Message "Another log text here" -LogLevel Warning -Component $Component
        This example writes a log entry with the text "Another log text here" and will be highlighted in yellow because of the log level being set to 'Warning'

    .EXAMPLE
        Write-CMTLog -Message "Yet another log text here" -LogLevel Error -Component $Component
        This example writes a log entry with the text "Yet another log text here" and will be highlighted in red because of the log level being set to 'Error'

    .NOTES
        Version: 1.0.1.0
        Author:  Simon Mellergård | Värnamo kommun | It-avdelningen
        Contact: simon.mellergard@varnamo.se
    #>

    [CmdletBinding()]

    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Message,
		
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet(
            'Normal',
            'Warning',
            'Error'
        )]
        [string]
        $LogLevel = 'Normal',

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $Component,

        # Log file path
        [Parameter(Mandatory = $true)]
        [string]
        $LogFilePath
    )

    switch ($LogLevel) {
        Normal  {[int]$LogLevel = 1}
        Warning {[int]$LogLevel = 2}
        Error   {[int]$LogLevel = 3}
    }

    $DateTime  = New-Object -ComObject WbemScripting.SWbemDateTime
    $DateTime.SetVarDate($(Get-Date))
    $UtcValue  = $DateTime.Value
    $UtcOffset = $UtcValue.Substring(21, $UtcValue.Length - 21)

    $ComponentName = "$($Component):$($MyInvocation.ScriptLineNumber)"
    $ExecUser      = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    $Computer      = $env:COMPUTERNAME

    # Create the line to be logged
    $LogLine =  "<![LOG[$($ExecUser): $Message]LOG]!>" +`
                "<time=`"$(Get-Date -Format HH:mm:ss.fff)$($UtcOffset)`" " +`
                "date=`"$(Get-Date -Format M-d-yyyy)`" " +`
                "component=`"$Computer\$ComponentName`" " +`
                "context=`"$($ExecUser)`" " +`
                "type=`"$LogLevel`" " +`
                "thread=`"$($pid)`" " +`
                "file=`"`">"

    
    # Write the line to the log file
    Add-Content -Value $LogLine -Path $LogFilePath -Encoding UTF8
}
# End function.