function Get-ADDisabledAccount {
    <#
        .SYNOPSIS
            Cmdlet to pull a list of disabled AD user accounts.
        .DESCRIPTION
            This cmdlet will pull a list of user accounts that are set to Disabled in the AD domain specified. 
        .PARAMETER DomainController
            The DomainController parameter refers to the FQDN of the Domain Controller that will be queried.
            It has an alias of Server.
        .PARAMETER SearchOU
            Name of the OU in AD that is to be queried. 
        .EXAMPLE
            Get-ADDisabledAccount -DomainController dc01.computer.local -SearchOU Admins,SrvAccounts
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
            [String[]]
            [Alias("Server")]
            $DomainController,
            
            [Parameter(Mandatory=$false,
                       Position=1)]
            [String[]]
            $SearchOU
        ) # end param
        
        begin {
            if (-not(Get-Module -Name ActiveDirectory -ListAvailable)) {
                Write-Verbose -Message "Installing the ActiveDirectory module..."
                if (Get-Command -Name Install-WindowsFeature) {
                    Install-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                }
                else {
                    Add-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                } # end if-else fix for Server 2008R2
            } # end if ActiveDirectory
        } # end begin
        
        process {
            # Foreach to account for multiple DomainController inputs
            foreach ($DC in $DomainController) {
                $Domain = Get-ADDomain -Server $DC
                $DN     = $Domain.DistinguishedName
                if ($SearchOU) {
                    foreach ($OU in $SearchOU) {
                        $SearchBase = "OU=$OU,$DN"
                        Write-Verbose -Message "Getting disabled AD accounts in $SearchBase"
                        Search-ADAccount -AccountDisabled -UsersOnly -SearchBase $SearchBase -Server $DC                
                    } # end foreach OU
                } else {
                    Write-Verbose -Message "Getting disabled AD accounts in $DN"
                    Search-ADAccount -AccountDisabled -UsersOnly -Server $DC 
                } # end if SearchOU
            } # end foreach DC
        } # end process
        
        end {
        } # end end
    } # end function Get-ADDisabledAccount 
    function Get-ADInactiveAccount {
        <#
        .SYNOPSIS
            Cmdlet to pull a list of AD user accounts that are inactive.
        .DESCRIPTION
            This cmdlet will pull a list of user accounts that have not logged in for a specified time period in the AD domain specified. 
        .PARAMETER DomainController
            The DomainController parameter refers to the FQDN of the Domain Controller that will be queried.
            It has an alias of Server.
        .PARAMETER SearchOU
            Name of the OU in AD that is to be queried.
        .PARAMETER Time
            The time length in days of how long it has been since an account last logged in. 
            The default is 90 days. 
        .PARAMETER IncludePasswordNeverExpires
            This is a switch parameter that will include accounts that have passwords set to not expire. 
        .EXAMPLE
            Get-ADInactiveAccount -Server 'dc01.mydomain.local' -Time 180
    
            This example will list all user accounts in the mydomain.local domain that have been inactive for 180 days and not disabled.
        .EXAMPLE
            Get-ADInactiveAccount -DomainController 'dc01.mydomain.local' -SearchOU Admins,Staff -IncludePasswordNeverExpires
    
            This example will list all user accounts in the mydomain.local domain in the Admins or Staff OUs that have passwords that have not logged in for 90 days. 
            It will also include accounts that have passwords set to not expire.
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
            [String[]]
            [Alias("Server")]
            $DomainController,
                
            [Parameter(Mandatory=$false,
                Position=1)]
            [String[]]
            $SearchOU,
    
            [Parameter(Mandatory=$false,
                Position=2)]
            [Int]
            [Alias("Days")]
            $Time = 90,
    
            [Parameter(Mandatory=$false,
                Position=3)]
            [switch]
            $IncludePasswordNeverExpires
        ) # end param
            
        begin {
            if (-not(Get-Module -Name ActiveDirectory -ListAvailable)) {
                Write-Verbose -Message "Installing the ActiveDirectory module..."
                if (Get-Command -Name Install-WindowsFeature) {
                    Install-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                }
                else {
                    Add-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                } # end if-else fix for Server 2008R2
            } # end if ActiveDirectory
    
            # Convert Time to properly formatted TimeSpan
            $TimeSpan = "$Time.00:00:00" 
        } # end begin
            
        process {
            # Foreach to account for multiple DomainController inputs
            foreach ($DC in $DomainController) {
                $Domain = Get-ADDomain -Server $DC
                $DN     = $Domain.DistinguishedName
                if ($SearchOU) {
                    foreach ($OU in $SearchOU) {
                        $SearchBase = "OU=$OU,$DN"
                        Write-Verbose -Message "Getting AD accounts that have not logged in in $Time days in $SearchBase"
                        # Not including accounts with passwords set to not expire unless specified in IncludePasswordNeverExpires
                        if ($IncludePasswordNeverExpires) {
                            Search-AdAccount -AccountInactive -TimeSpan $TimeSpan -UsersOnly -Server $DC -SearchBase $SearchBase | Where-Object Enabled -eq $true
                        } else {
                            Search-AdAccount -AccountInactive -TimeSpan $TimeSpan -UsersOnly -Server $DC -SearchBase $SearchBase | Where-Object {$_.Enabled -eq $true -and $_.PasswordNeverExpires -eq $false}
                        } # end if-else IncludePasswordNeverExpires
                    } # end foreach
                } else {
                    Write-Verbose -Message "Getting AD accounts that have not logged in in $Time days in $DN"
                    # Not including accounts with passwords set to not expire unless specified in IncludePasswordNeverExpires
                    if ($IncludePasswordNeverExpires) {
                        Search-AdAccount -AccountInactive -TimeSpan $TimeSpan -UsersOnly -Server $DC | Where-Object Enabled -eq $true
                    } else {
                        Search-AdAccount -AccountInactive -TimeSpan $TimeSpan -UsersOnly -Server $DC | Where-Object {$_.Enabled -eq $true -and $_.PasswordNeverExpires -eq $false}
                    } # end if-else IncludePasswordNeverExpires
                } # end if SearchOU
            } # end foreach DC
        } # end process
            
        end {
        } # end end
    } # end function Get-ADInactiveAccount
    function Get-ADPasswordNeverExpires {
        <#
            .SYNOPSIS
                Cmdlet to list enabled AD accounts with passwords that do not expire.
            .DESCRIPTION
                This cmdlet will list the AD account that have passwords that never expire and is limited to only Enabled accounts. 
            .PARAMETER DomainController
                The DomainController parameter refers to the FQDN of the Domain Controller that will be queried.
                It has an alias of Server.
            .PARAMETER SearchOU
                Name of the OU in AD that is to be queried.
            .PARAMETER IncludeDisabled
                This is a switch parameter that will include disabled user accounts if used. 
            .EXAMPLE
                Get-ADPasswordNeverExpires -Server 'dc01.mydomain.local'
    
                This example will list all user accounts in the mydomain.local domain that are enabled and have passwords that do not expire.
            .EXAMPLE
                Get-ADPasswordNeverExpires -DomainController 'dc01.mydomain.local' -SearchOU Admins,Staff -IncludeDisabled
    
                This example will list all user accounts in the mydomain.local domain in the Admins or Staff OUs that have passwords that do not expire. 
                It will also include disabled accounts.
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
            [String[]]
            [Alias("Server")]
            $DomainController,
                
            [Parameter(Mandatory=$false,
                Position=1)]
            [String[]]
            $SearchOU,
    
            [Parameter(Mandatory=$false,
                Position=2)]
            [switch]
            $IncludeDisabled
        ) # end param
            
        begin {
            if (-not(Get-Module -Name ActiveDirectory -ListAvailable)) {
                Write-Verbose -Message "Installing the ActiveDirectory module..."
                if (Get-Command -Name Install-WindowsFeature) {
                    Install-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                }
                else {
                    Add-WindowsFeature -Name RSAT-AD-PowerShell -ErrorAction Stop
                } # end if-else fix for Server 2008R2
            } # end if ActiveDirectory
        } # end begin
            
        process {
            # Foreach to account for multiple DomainController inputs
            foreach ($DC in $DomainController) {
                $Domain = Get-ADDomain -Server $DC
                $DN     = $Domain.DistinguishedName
                if ($SearchOU) {
                    foreach ($OU in $SearchOU) {
                        $SearchBase = "OU=$OU,$DN"
                        Write-Verbose -Message "Getting AD accounts with never expiring passwords in $SearchBase"
                        # Not including disabled accounts unless specified in InlcudeDisabled
                        if ($IncludeDisabled) {
                            Search-ADAccount -PasswordNeverExpires -UsersOnly -SearchBase $SearchBase -Server $DC
                        } else {
                            Search-ADAccount -PasswordNeverExpires -UsersOnly -SearchBase $SearchBase -Server $DC | Where-Object Enabled -eq $true
                        }
                    } # end foreach OU
                } else {
                    # Not including disabled accounts unless specified in InlcudeDisabled
                    Write-Verbose -Message "Getting AD accounts with never expiring passwords in $DN"
                    if ($IncludeDisabled) {
                        Search-ADAccount -PasswordNeverExpires -UsersOnly -Server $DC
                    } else {
                        Search-ADAccount -PasswordNeverExpires -UsersOnly -Server $DC | Where-Object Enabled -eq $true
                    }
                } # end if SearchOU
            } # end foreach DC
        } # end process
            
        end {
        } # end end
    } # end function Get-ADPasswordNeverExpires
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