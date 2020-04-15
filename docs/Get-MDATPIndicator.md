---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPIndicator

## SYNOPSIS
Get-MDATPIndicator

## SYNTAX

```
Get-MDATPIndicator [[-IndicatorType] <String>] [[-MTPConfigFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPIndicator retrieves Microsoft Defender Advanced Threat Protection custom indicators exposed
through the Microsoft Defender Advanced Threat Protection indicators Rest API.

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPIndicator
```

This command retrieves all TI indicators

### EXAMPLE 2
```
Get-MDATPIndicator -IndicatorType DomainName
```

This command retrieves all DomainName TI indicators

### EXAMPLE 3
```
$indicators = Get-MDATPIndicator -MTPConfigFile "C:\Dev\Private\MSSecurityPowerShell\Config\PoshMTPconfigBaseVISION.json"
$indicators | Where-Object {$_.Source -like "WindowsDefenderATPThreatIntelAPI"}
```


This sample shows how to filter results by TI source

## PARAMETERS

### -IndicatorType
Filters the indicator by the specified IndicatorType.
Possible values are: DomainName, Url, FileSha256,IpAddress,WebCategory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MTPConfigFile
The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the ..\config\ folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Version:        1.0
Author:         Alex Verboon
Creation Date:  20.03.2020
Purpose/Change: Initial script development

## RELATED LINKS

