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