---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Stop-MDATPAppRestriction

## SYNOPSIS
Stop-MDATPAppRestriction

## SYNTAX

### DeviceName
```
Stop-MDATPAppRestriction -DeviceName <String> [-Comment <String>] [-MTPConfigFile <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### DeviceID
```
Stop-MDATPAppRestriction -DeviceID <String> [-Comment <String>] [-MTPConfigFile <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Stop-MDATPAppRestriction removes app execution restrictions on the machine.

## EXAMPLES

### EXAMPLE 1
```
Stop-MDATPAppRestriction -DeviceName computer02 -Comment "incident1973"
```

This command removes app execution restrictions from  device computer02

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
