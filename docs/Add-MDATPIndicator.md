---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Add-MDATPIndicator

## SYNOPSIS
Add-MDATPIndicator

## SYNTAX

```
Add-MDATPIndicator [-IndicatorValue] <String> [-IndicatorType] <String> [-Action] <String>
 [[-Application] <String>] [-Title] <String> [-Description] <String> [[-expirationTime] <String>]
 [-severity] <String> [[-recommendedActions] <String>] [[-MTPConfigFile] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Add-MDATPIndicator Submits or Updates new Indicator entity.

## EXAMPLES

### EXAMPLE 1
```
Add-MDATPIndicator -IndicatorValue "https://www.sample.com" -IndicatorType Url -Action Alert -Title "Sample URL detected" -Description "Access to the website sample.com detected" -severity High
```

This command adds the URL indicator for https://www.sample.com

### EXAMPLE 2
```
Add-MDATPIndicator -IndicatorType DomainName www.somedomain.com -Action Alert -Title "somedomain domain detected" -Description "somedomain domain detected from custom indicator" -severity Informational
```

This command ads the domain indicator for www.somedomain.com

### EXAMPLE 3
```
Add-MDATPIndicator -IndicatorValue "A4B52BBC94F10572296D3F8F4E25B39A1837D00F3036955C3761A9E7B2207A58" -IndicatorType FileSha256 -Action Alert -Title "Dummy File" -severity Informational -Description "dummy file detected"
```

This command creates FileSha256 indicator

### EXAMPLE 4
```
Add-MDATPIndicator -IndicatorType IpAddress -IndicatorValue 138.223.70.10 -Action Alert -Title "IP Address indicator 138.223.70.10" -Description "access detected" -severity Medium
```

This command adds an IP indicator

## PARAMETERS

### -IndicatorValue
Identity of the Indicator entity.
Required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndicatorType
Type of the indicator.
Possible values are: "FileSha1", "FileSha256", "IpAddress", "DomainName" and "Url".
Required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Action
The action that will be taken if the indicator will be discovered in the organization.
Possible values are: "Alert", "AlertAndBlock", and "Allowed".
Required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Application
The application associated with the indicator.
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Indicator alert title.
Required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Description of the indicator.
Required

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -expirationTime
The expiration time of the indicator.
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -severity
The severity of the indicator.
possible values are: "Informational", "Low", "Medium" and "High".
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -recommendedActions
TI indicator alert recommended actions.
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
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
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
Creation Date:  05.05.2020
Purpose/Change: Initial script development

## RELATED LINKS
