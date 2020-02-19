---
external help file: AdTools-help.xml
Module Name: AdTools
online version:
schema: 2.0.0
---

# Get-ADInactiveAccount

## SYNOPSIS
Cmdlet to pull a list of AD user accounts that are inactive.

## SYNTAX

```
Get-ADInactiveAccount [-DomainController] <String[]> [[-SearchOU] <String[]>] [[-Time] <Int32>]
 [-IncludePasswordNeverExpires] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will pull a list of user accounts that have not logged in for a specified time period in the AD domain specified.

## EXAMPLES

### EXAMPLE 1
```
Get-ADInactiveAccount -Server 'dc01.mydomain.local' -Time 180
```

This example will list all user accounts in the mydomain.local domain that have been inactive for 180 days and not disabled.

### EXAMPLE 2
```
Get-ADInactiveAccount -DomainController 'dc01.mydomain.local' -SearchOU Admins,Staff -IncludePasswordNeverExpires
```

This example will list all user accounts in the mydomain.local domain in the Admins or Staff OUs that have passwords that have not logged in for 90 days. 
It will also include accounts that have passwords set to not expire.

## PARAMETERS

### -DomainController
The DomainController parameter refers to the FQDN of the Domain Controller that will be queried.
It has an alias of Server.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Server

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SearchOU
Name of the OU in AD that is to be queried.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Time
The time length in days of how long it has been since an account last logged in. 
The default is 90 days.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Days

Required: False
Position: 3
Default value: 90
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePasswordNeverExpires
This is a switch parameter that will include accounts that have passwords set to not expire.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### None
## NOTES
Author: Aaron Weisman
Updated: 2/19/2020

## RELATED LINKS
