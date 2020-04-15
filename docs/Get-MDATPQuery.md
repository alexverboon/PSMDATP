---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPQuery

## SYNOPSIS
Get-MDATPQuery

## SYNTAX

```
Get-MDATPQuery [-Schema] <String> [[-DeviceName] <String>] [[-TimeRange] <String>] [[-MTPConfigFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPQuery executes MDATP advanced hunting queries through the
Microsoft Defender Advanced Threat Protection Alerts Rest API.

Limitations
1.
You can only run a query on data from the last 30 days.
2.
The results will include a maximum of 100,000 rows.
3.
The number of executions is limited per tenant: up to 15 calls per minute, 15 minutes of running time every hour and 4 hours of running time a day.
4.
The maximal execution time of a single request is 10 minutes.

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPQuery -Schema DeviceLogonEvents -DeviceName TestClient4
```

The above query retrieves all logon events for the specified device

## PARAMETERS

### -Schema
The Schema to use for the query

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

### -DeviceName
Computername of the device.If no DeviceName is provided all devices are querried

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

### -TimeRange
The Time Range

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

### -MTPConfigFile
The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json is used
that must be located in the ..\config\ folder.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Version:        1.0
Author:         Alex Verboon
Creation Date:  17.02.2020
Purpose/Change: Initial script development

## RELATED LINKS
