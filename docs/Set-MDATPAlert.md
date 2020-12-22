---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Set-MDATPAlert

## SYNOPSIS
Set-MDATPAlert

## SYNTAX

```
Set-MDATPAlert [-AlertID] <String> [[-status] <String>] [[-assignedTo] <String>] [[-classification] <String>]
 [[-determination] <String>] [[-comments] <String>] [[-MTPConfigFile] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Set-MDATPAlert updates a Microsoft Defender Advanced Threat Protection alert through the Microsoft Defender Advanced Threat Protection Alerts Rest API.

## EXAMPLES

### EXAMPLE 1
```
Set-WDATPAlert -AlertID 121688558380765161_2136280442 -status Resolved -assignedTo secop2@contoso.com -classification FalsePositive -determination Malware -comments "Resolve my alert and assign to secop2
```

## PARAMETERS

### -AlertID
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

### -status
The status that will be set for the alert in the organization.
Possible values are: "New", "InProgress", and "Resolved".
Optional

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

### -assignedTo
The userid that will be set for assigned to field for the the alert in the organization.
Example: secop2@contoso.com.
Optional

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

### -classification
The classification that will be set for the alert in the organization.
Possible values are: "Unknown", "FalsePositive", and "TruePositive".
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

### -determination
The determination that will be set for the alert in the organization.
Possible values are: "NotAvailable", "Apt", "Malware", "SecurityPersonnel", "SecurityTesting", "UnwantedSoftware", and "Other".
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -comments
The comment field that will be set for the the alert in the organization.
Optional

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
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
Position: 7
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
Author:         Daniel Lacher
Creation Date:  02.11.2020
Purpose/Change: Initial pass at creation of function to allow for update to MDATP Alerts via API and PSMDATP framework.

## RELATED LINKS
