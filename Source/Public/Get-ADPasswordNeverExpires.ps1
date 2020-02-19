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