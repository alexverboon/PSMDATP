---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPEndpointStatus

## SYNOPSIS
Get-MDATPEndpointStatus

## SYNTAX

```
Get-MDATPEndpointStatus [[-DeviceName] <String>] [[-MTPConfigFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPEndpointStatus retrieves information about the Endpoint Status

https://github.com/microsoft/Microsoft-365-Defender-Hunting-Queries/blob/master/General%20queries/Endpoint%20Agent%20Health%20Status%20Report.md

This query will provide a report of many of the best practice configurations for Defender ATP deployment.
Special Thanks to Gilad Mittelman for the initial inspiration and concept.
Any tests which are reporting "BAD" as a result imply that the associated capability is not configured per best practice recommendation.

Limitations
1.
The results will include a maximum of 100,000 rows.
2.
The number of executions is limited per tenant: up to 15 calls per minute, 15 minutes of running time every hour and 4 hours of running time a day.
3.
The maximal execution time of a single request is 10 minutes.

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPEndpointStatus -DeviceName TestClient4
```

### EXAMPLE 2
```
Get-MDATPEndpointStatus
```

## PARAMETERS

### -DeviceName
Computername of the device.If no DeviceName is provided all devices are querried

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
Creation Date:  22.12.2020
Purpose/Change: Initial script development

## RELATED LINKS
