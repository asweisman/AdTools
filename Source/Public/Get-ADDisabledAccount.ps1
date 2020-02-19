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