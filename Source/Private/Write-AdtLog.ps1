function Write-AdtLog {
<#
    .SYNOPSIS
        Function to log input to a log file.
    .DESCRIPTION
        This function takes specific Info, Warning, Debug, or Error information and logs it to a file.  
    .PARAMETER Message
        Information to be logged.
    .PARAMETER Level
        Level of the information that needs to be logged. The four options are: INFO, WARNING, ERROR, DEBUG.
        The default Level is INFO.
    .PARAMETER Path
        Defines the path where the log file is created. 
        The default path is $ENV:ProgramDate\AdTools\AdtLog.log
    .PARAMETER Clear
        Clears out the log file to start with a blank file.
    .EXAMPLE
        Write-AdtLog -Message "This is a warning message" -Level Warning -Clear
        
        Starts a new log file with the specified warning message. 
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Author: Aaron Weisman
        Updated: 2/19/2020
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]
        $Message,
        
        [Parameter(Mandatory=$false,
                   Position=1)]
        [ValidateSet('Info', 'Error', 'Warning', 'Debug')]
        [String]
        $Level = 'Info',

        [Parameter(Mandatory=$false,
                    Position=2)]
        [String]
        $Path = "$ENV:ProgramData\AdTools\AdtLog.log",

        [Parameter(Mandatory=$false,
                    Position=4)]
        [switch]
        $Clear
    ) # end param
    
    begin {
        if (Test-Path -Path $Path) {
            if ($Clear) {
                Remove-Item -Path $Path -Force
            } # end if Clear
        } else {
            # Create the log file and path if it doesn't exist.
            # Out-Null prevent any output from the file creation.
            New-Item -Path $Path -Force | Out-Null
        } # end if-else Test-Path
    } # end begin
    
    process {
        switch ($Level) {
            'Info' {
                 $LevelText = "INFO:    ";
                 break
            } # end Info
            'Error' {
                $LevelText = "ERROR:    ";
                 break
            } # end Error
            'Warning' {
                $LevelText = "WARNING:  ";
                 break
            } # end Warning
            'Debug' {
                $LevelText = "DEBUG:    ";
                 break
            } # end Debug
        } # end switch Level

        $LogObj = [PSCustomObject][ordered]@{
            TimeStamp   = Get-Date -Format "MM-dd-yyyy:HH:mm:ss"
            Level       = $LevelText
            Message     = $Message
        } # end LogObj

        $LogObj | Export-Csv -Path $Path -Delimiter "`t" -NoTypeInformation -Append
        
        # Write Verbose in case the user wants to view the message
        Write-Verbose -Message $LogObj
    } # end process
    
    end {
    } # end end
} # end function Write-AdtLog