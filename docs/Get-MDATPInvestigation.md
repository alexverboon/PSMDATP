---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPInvestigation

## SYNOPSIS
Get-MDATPInvestigation

## SYNTAX

### All (Default)
```
Get-MDATPInvestigation [-All] [-State <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

### DeviceName
```
Get-MDATPInvestigation [-DeviceName <String>] [-State <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

### DeviceID
```
Get-MDATPInvestigation [-DeviceID <String>] [-State <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

### id
```
Get-MDATPInvestigation [-Id <String>] [-State <String>] [-MTPConfigFile <String>] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPInvestigation retrieves Microsoft Defender ATP automated investigation information

## EXAMPLES

### EXAMPLE 1
```
Get-MDATPInvestigation
```

This command retrieves all investigations

### EXAMPLE 2
```
Get-MDATPInvestigation -DeviceName Computer01
```

This command retrieves all investigations for Computer01

### EXAMPLE 3
```
Get-MDATPInvestigation -DeviceID 70077ccc272ab3baeb991c09442c5657d22bfc5c
```

This command retrieves all investigations for the device with the specified
device id.

### EXAMPLE 4
```
Get-MDATPInvestigation -State Running
```

This command retireves all investigations with the state Running

### EXAMPLE 5
```
Get-MDATPInvestigation -Id 12
```

This command retrieves investigation details for the investigation with id 12

### EXAMPLE 6
```
Get-MDATPInvestigation -DeviceName computer01 -State SuccessfullyRemediated
```

This command retrieves all SuccessfullyRemediated investigations for device computer01

## PARAMETERS

### -All
Switch to list all devices

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceName
Computername of the device

```yaml
Type: String
Parameter Sets: DeviceName
Aliases:

Required: False
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

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
The investigation id

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

### -State
The current state of the investigation.
Possible values are:
Unknown, Terminated, SuccessfullyRemediated, Benign, Failed, PartiallyRemediated, Running, PendingApproval, PendingResource, PartiallyInvestigated, TerminatedByUser, TerminatedBySystem, Queued, InnerFailure, PreexistingAlert, UnsupportedOs, UnsupportedAlertType, SuppressedAlert

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
Creation Date:  12.04.2020
Purpose/Change: Initial script development

## RELATED LINKS
