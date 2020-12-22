---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPAlert

## SYNOPSIS
Get-MDATPAlert

## SYNTAX

```
Get-MDATPAlert [[-Severity] <String>] [[-PastHours] <String>] [[-MTPConfigFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPAlert retrieves Microsoft Defender Advanced Threat Protection alerts exposed  through the Microsoft Defender Advanced Threat Protection Alerts Rest API.

## EXAMPLES

### EXAMPLE 1
```
Get-WDATPAlert
```

This command retrieves all alerts

### EXAMPLE 2
```
Get-MDATPAlert -PastHours 168 -Severity Informational
```

This command retrieves all alerts from the past 7 days with severity level Informational

## PARAMETERS

### -Severity
Provides an option to filter the output by Severity.
Low, Medium, High.

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

### -PastHours
Provides an option to filter the results by past hours when the alert was created.

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

### -MTPConfigFile
The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Version:        1.2
Author:         Alex Verboon
Creation Date:  18.07.2020
Purpose/Change: updated API uri

## RELATED LINKS
