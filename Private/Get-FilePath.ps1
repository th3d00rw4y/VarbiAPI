function Get-FilePath {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER InitialDirectory
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]

    param (
        # Directory where to start the file prompt
        [Parameter()]
        [string]
        $InitialDirectory
    )
    
    begin {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    }
    
    process {
        $OpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter           = "All files (*.*)| *.*"
        $OpenFileDialog.ShowDialog() | Out-Null
        
    }
    
    end {
        return $OpenFileDialog.filename
    }
}
# End function.