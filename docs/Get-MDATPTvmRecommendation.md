---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPTvmRecommendation

## SYNOPSIS
Get-MDATPTvmRecommendation

## SYNTAX

```
Get-MDATPTvmRecommendation [[-recommendationCategory] <String>] [-publicexploit] [[-MTPConfigFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPTvmRecommendation retrieves Microsoft Defender Advanced Threat Protection Threat and Vulnerability Management
security recommendations

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPTvmRecommendation
```

This command retrieves all TVM security recommendations

### EXAMPLE 2
```
$tvmrecommendations = Get-MDATPTvmRecommendation -MTPConfigFile "C:\Users\Alex\Documents\WindowsPowerShell\Modules\PSMDATP\PoshMTPconfig.json"
```

## PARAMETERS

### -recommendationCategory
Category or grouping to which the configuration belongs: Application, OS, Network, Accounts, Security controls

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

### -publicexploit
Setting this parameter limits the results to security recommendations that address a public exploit

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
Creation Date:  18.07.2020
Purpose/Change: Initial script development

## RELATED LINKS
