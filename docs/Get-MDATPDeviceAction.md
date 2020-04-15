---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPDeviceAction

## SYNOPSIS
Get-MDATPDeviceAction

## SYNTAX

### DeviceName
```
Get-MDATPDeviceAction -DeviceName <String> [-ActionType <String>] [-MTPConfigFile <String>]
 [<CommonParameters>]
```

### DeviceID
```
Get-MDATPDeviceAction -DeviceID <String> [-ActionType <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

### All
```
Get-MDATPDeviceAction [-All] [-ActionType <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

### id
```
Get-MDATPDeviceAction [-Id <String>] [-ActionType <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPDeviceAction retrieves machine MDATP actions

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPDeviceAction -DeviceName computer02
This command retrieves the actions for device 'computer02'
```


EXAMPLE
Get-MDATPDeviceAction -DeviceID 70077ccc272ab3baeb991c09442c5657d22bfc5c

This command retrieves the actions for the device with the specified device id

### EXAMPLE 2
```
Get-MDATPDeviceAction -ActionType CollectInvestigationPackage
```

This command retreives all machine actions with the specified action type

### EXAMPLE 3
```
Get-MDATPDeviceAction -All
```

This command retrieves machine actions for all devices

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

### -Id
The machine action id

```yaml
Type: String
Parameter Sets: id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActionType
Action Type

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
Creation Date:  12.04.2020
Purpose/Change: Initial script development

## RELATED LINKS

