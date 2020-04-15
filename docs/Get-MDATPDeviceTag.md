---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPDeviceTag

## SYNOPSIS
Get-MDATPDeviceTag

## SYNTAX

### DeviceName
```
Get-MDATPDeviceTag -DeviceName <String> [-MTPConfigFile <String>] [<CommonParameters>]
```

### DeviceID
```
Get-MDATPDeviceTag -DeviceID <String> [-MTPConfigFile <String>] [<CommonParameters>]
```

### All
```
Get-MDATPDeviceTag [-All] [-MTPConfigFile <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPDeviceTag retrieves tags assigned on the specified device

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPDeviceTag -DeviceName computer02
```

This command reads all the tags assigned to the device 'computer02'

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
Switch to retrieve tags from all devices

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

### -MTPConfigFile
The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json is used
that must be located in the ..\config\ folder.

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
Creation Date:  16.03.2020
Purpose/Change: Initial script development

## RELATED LINKS
