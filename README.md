# Microsoft Defender for Endpoint PowerShell Module

[![Minimum Supported PowerShell Version](https://img.shields.io/badge/PowerShell-5.1+-purple.svg)](https://github.com/PowerShell/PowerShell) ![Cross Platform](https://img.shields.io/badge/platform-windows-lightgrey)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/psmdatp)](https://www.powershellgallery.com/packages/PSMDATP) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/psmdatp)](https://www.powershellgallery.com/packages/PSMDATP)


<p align="center">
    <img src="./media/small_psmdatp.png" alt="PSMDATP Logo" >
</p>

Welcome to the Microsoft Defender for Endpoint PowerShell module!

This module is a collection of easy-to-use cmdlets and functions designed to make it easy to interface with the Microsoft Defender for Endpoint API.

## Motivation

I created this PowerShell module for MDATP for the following reasons:

1. Advance my PowerShell skills
2. Provide an easy way to interact with MDE through PowerShell because I prefer automation over manual tasks

## Prerequisites

- Windows PowerShell 5.1 (Testing for PowerShell 7 is in progress)
- have configured authorization for access by registering an application in AzureAD

### App Permissions

Below is an example of the App Permissions that you must grant. I will provide more details soon about the individual cmdlets and the permissions required

<p align="center">
    <img src="./media/apppermissions.png" alt="App permissions" >
</p>


## Getting Started

To get started with the module, open your PowerShell terminal and install the module from the PSGallery by running this simple command:
```powershell
Install-Module PSMDATP -Scope CurrentUser
```
## App Registration

## Initial Configuration

When you have installed the module and registered the App in AzureAD, you will find a file **TEMPLATE_PoshMTPconfig.json** in the Module folder. Rename this file to **PoshMTPConfig.json** and enter your API settings. Then copy the file in the root of the Module folder.

***Example:***

```powershell
"C:\Users\User1\Documents\WindowsPowerShell\Modules\PSMDATP"
───PSMDATP
│   │   PoshMTPconfig.json
│   │
│   └───0.0.2
│           PSMDATP.psd1
│           PSMDATP.psm1
│           TEMPLATE_PoshMTPconfig.json
```

At present the PSMDATP PowerShell module only requires the API_MDATP information

```json
{
    "API_MDATP":  {
                      "AppName":  "WindowsDefenderATPPSMDATP",
                      "OAuthUri":  "https://login.windows.net/<YOUR TENANT ID>/oauth2/token",
                      "ClientID":  "CLIENT ID",
                      "ClientSecret":  "<CLIENT SECRET>"
                  },
    "API_MSGRAPH":  {
                        "AppName":  "xMSGraph",
                        "OAuthUri":  "https://login.windows.net/<YOUR TENANT ID>/oauth2/token",
                        "ClientID":  "<CLIENT ID>",
                        "ClientSecret":  "<CLIENT SECRET>"
                    }
}
```

## Important

I am going to assume that you are familiar with MDATP as such and understand the consequences of triggering actions on devices. Where applicable the cmdlets support the use the ***-whatif*** parameter. Think before pressing the key!

## Running your first commands

### List included cmdlets

Let's first take a look at the cmdlets included in the PSMDATP Module

```powershell
get-command -Module PSMDATP | Select Name
```

You will see something like this

```powershell

Add-MDATPDeviceTag
Add-MDATPIndicator
Get-MDATPAlert
Get-MDATPCollectionPackageUri
Get-MDATPDevice
Get-MDATPDeviceAction
Get-MDATPDeviceTag
Get-MDATPIndicator
Get-MDATPInvestigation
Get-MDATPQuery
Get-MDATPTvmRecommendation
Get-MDATPTvmVulnerability
Get-MDATPEndpointStatus
Remove-MDATPDevice
Remove-MDATPDeviceTag
Remove-MDATPIndicator
Set-MDATPAlert
Start-MDATPAppRestriction
Start-MDATPAVScan
Start-MDATPInvestigation
Start-MDATPInvestigationPackageCollection
Start-MDATPIsolation
Stop-MDATPAppRestriction
Stop-MDATPIsolation

```

For more details about the cmdlets included in this module check out the [cmdlets documentation page](./docs/PSMDATP.md)

### Retrieve MDATP Alerts

Run the following command to retrieve alerts from the past 30 days

```powershell
Get-MDATPAlert -Severity High
```

### List MDATP Devices

Run the following command to list all MDATP registered devices

```powershell
Get-MDATPDevice -All
```

---

## Contributing

If you have an idea or want to contribute to this project please submit a suggestion

## Authors

**Alex Verboon** [Twitter](https://twitter.com/alexverboon)

## Contributors

**Dan Lacher** [Twitter](https://twitter.com/DanLacher)

---

## Release Notes

| Version |    Date    |                           Notes                                |
| ------- | ---------- | -------------------------------------------------------------- |
| 0.0.1   | 15.04.2020 | Initial Release                                                |
| 0.0.2   | 03.05.2020 | Added Add-MDATPIndicator and Remove-MDATPIndictor cmdlets      |
| 1.0.0   | 18.07.2020 | Added Get-MDATPTvmRecommendation and Get-MDATPTvmVulnerability |
|         |            | cmdlets, updated the API uri for the Get-MDATPAlerts cmdlet    |
| 1.1.0   | 22.12.2020 | Added Set-MDATPAlert and Get-MDATPEndpointStatus               |
| 1.1.1   | 22.11.2022 | Added generateAlert flag to Add-MDATPIndicator                 |

---

## TODO

I have the following on my to-do list:

- A better solution to store the API configuration in a more secure place
- ~~Add cmdlets for TVM~~ added in version 1.0.0
- ~~Add cmdlets to manage custom indicators~~ added in version 0.0.2
- Add more query templates for advanced hunting
- Create more Module related Pester tests

---

## Credits

I used [Catesta](https://github.com/techthoughts2/Catesta/blob/master/README.md) for this project