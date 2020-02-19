---
external help file: AdTools-help.xml
Module Name: AdTools
online version:
schema: 2.0.0
---

# Get-ADPasswordNeverExpires

## SYNOPSIS
Cmdlet to list enabled AD accounts with passwords that do not expire.

## SYNTAX

```
Get-ADPasswordNeverExpires [-DomainController] <String[]> [[-SearchOU] <String[]>] [-IncludeDisabled]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will list the AD account that have passwords that never expire and is limited to only Enabled accounts.

## EXAMPLES

### EXAMPLE 1
```
Get-ADPasswordNeverExpires -Server 'dc01.mydomain.local'
```

This example will list all user accounts in the mydomain.local domain that are enabled and have passwords that do not expire.

### EXAMPLE 2
```
Get-ADPasswordNeverExpires -DomainController 'dc01.mydomain.local' -SearchOU Admins,Staff -IncludeDisabled
```

This example will list all user accounts in the mydomain.local domain in the Admins or Staff OUs that have passwords that do not expire. 
It will also include disabled accounts.

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

### -IncludeDisabled
This is a switch parameter that will include disabled user accounts if used.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
