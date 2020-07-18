---
external help file: PSMDATP-help.xml
Module Name: PSMDATP
online version:
schema: 2.0.0
---

# Get-MDATPCollectionPackageUri

## SYNOPSIS
Get-MDATPCollectionPackageUri

## SYNTAX

```
Get-MDATPCollectionPackageUri [-ActionID] <String> [[-MTPConfigFile] <String>] [-Download] [<CommonParameters>]
```

## DESCRIPTION
Get-MDATPCollectionPackageUri retrieves the Investigation Collection Package download URI and optionally download the package

Use the Get-MDATPDeviceActions cmdlet to retrieve the ActionID of the investigation package collection request.

## EXAMPLES

### EXAMPLE 1
```
$lastcollectionrequestid = Get-MDATPDeviceActions -DeviceName testclient6 -ActionType CollectInvestigationPackage | Select-Object -First 1
Get-MDATPCollectionPackageUri -ActionID $lastcollectionrequestid.id
```


This comand first retrieves the last collection package request ID and then retrieves the download URI

### EXAMPLE 2
```
$lastcollectionrequestid = Get-MDATPDeviceActions -DeviceName testclient6 -ActionType CollectInvestigationPackage | Select-Object -First 1
Get-MDATPCollectionPackageUri -ActionID $lastcollectionrequestid.id -Download
```


This comand first retrieves the last collection package request ID and stores the investigation package into the users download folder

## PARAMETERS

### -ActionID
The Action ID of the investigation package collection request.

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

### -Download
Downloads the investigation pacakge ZIP file into the users Downloads folder

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

