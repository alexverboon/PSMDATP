---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Start-MDATPIsolation

## SYNOPSIS
Start-MDATPIsolation

## SYNTAX

### DeviceName
```
Start-MDATPIsolation -DeviceName <String> -IsolationType <String> [-Comment <String>] [-MTPConfigFile <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### DeviceID
```
Start-MDATPIsolation -DeviceID <String> -IsolationType <String> [-Comment <String>] [-MTPConfigFile <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Start-MDATPIsolation initiates the isolation of the specified device from the network

## EXAMPLES

### EXAMPLE 1
```
Start-MDATPIsolation -DeviceName computer02 -IsolationType Full -Comment "incident1973"
```

This command isolates device computer02 from the network

### EXAMPLE 2
```
Start-MDATPIsolation -DeviceName computer02 -IsolationType Selective -Comment "incident1973"
```

This command isolates device computer02 from the network but allows communication through Outlook and Skype

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

### -IsolationType
Type of the isolation.
Allowed values are: 'Full' or 'Selective'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
Comment that is added to the request, if no comment is provided the default commment 'submitted by automation' is used.

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
Creation Date:  12.04.2020
Purpose/Change: Initial script development

## RELATED LINKS
