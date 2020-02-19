---
external help file: AdTools-help.xml
Module Name: AdTools
online version:
schema: 2.0.0
---

# Get-ADDisabledAccount

## SYNOPSIS
Cmdlet to pull a list of disabled AD user accounts.

## SYNTAX

```
Get-ADDisabledAccount [-DomainController] <String[]> [[-SearchOU] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will pull a list of user accounts that are set to Disabled in the AD domain specified.

## EXAMPLES

### EXAMPLE 1
```
Get-ADDisabledAccount -DomainController dc01.computer.local -SearchOU Admins,SrvAccounts
```

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
