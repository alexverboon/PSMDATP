---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPDevice

## SYNOPSIS
Get-MDATPDevice

## SYNTAX

### DeviceName
```
Get-MDATPDevice -DeviceName <String> [-MTPConfigFile <String>] [<CommonParameters>]
```

### DeviceID
```
Get-MDATPDevice -DeviceID <String> [-MTPConfigFile <String>] [<CommonParameters>]
```

### All
```
Get-MDATPDevice [-All] [-HealthStatus <String>] [-RiskScore <String>] [-MTPConfigFile <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPDevice retrieves MDATP device information

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPDevice -all
```

This command retrieves all MDATP devices

### EXAMPLE 2
```
Get-MDATPDevice -All -HealthStatus Inactive
```

This command lists all inactive devices

### EXAMPLE 3
```
Get-MDATPDevice -All -RiskScore Medium
```

This command lists all devices with a medium risk score

### EXAMPLE 4
```
Get-MDATPDevice -DeviceName Computer01
```

This command retrieves device information for Computer01

## PARAMETERS

### -DeviceName
Computername of the device

```yaml
Type: String
Parameter Sets: DeviceName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceID
The unique device ID of the device

```yaml
Type: String
Parameter Sets: DeviceID
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Lists machine actions for all managed devices

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HealthStatus
Filters the results by device heatlh.

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RiskScore
Filters the results by device risk score

```yaml
Type: String
Parameter Sets: All
Aliases:

Required: False
Position: Named
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
Creation Date:  14.04.2020
Purpose/Change: Initial script development

## RELATED LINKS
