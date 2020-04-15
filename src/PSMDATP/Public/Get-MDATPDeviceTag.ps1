function Get-MDATPDeviceTag{
    <#
    .Synopsis
    Get-MDATPDeviceTag

    .Description
    Get-MDATPDeviceTag retrieves tags assigned on the specified device

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder


    .EXAMPLE
        Get-MDATPDeviceTag -DeviceName computer02

        This command reads all the tags assigned to the device 'computer02'

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  16.03.2020
    Purpose/Change: Initial script development
    #>

    [CmdletBinding()]
    Param(
        # Computername of the MDATP managed device
        [Parameter(Mandatory=$true,
            ParameterSetName='DeviceName')]
        [ValidateNotNullOrEmpty()]
        [String]$DeviceName,

        # Unique device id of the MDATP managed device
        [Parameter(Mandatory=$true,
            ParameterSetName='DeviceID')]
        [ValidateNotNullOrEmpty()]
        [String]$DeviceID,

        # Switch to retrieve tags from all devices
        [Parameter(Mandatory=$true,
            ParameterSetName='All')]
        [switch]$All,

        # API Configuration
        [Parameter(Mandatory=$false)]
        [String]$MTPConfigFile
    )

    Begin{
        # Begin Get API Information
        If ($MTPConfigFile){
            $PoshMTPconfigFilePath = $MTPConfigFile
            Write-Verbose "MTP ConfigFile parameter: $PoshMTPconfigFilePath"
        }
        Else{
            # If no configfile is defined we use a defined lcoation .\Config\PoshMTPconfig.json
            $ConfigFileDir =  [IO.Directory]::GetParent($PSScriptRoot)
            $PoshMTPconfigFilePath = "$ConfigFileDir\" +  "PoshMTPconfig.json"
            Write-Verbose "MTP ConfigFile static: $PoshMTPconfigFilePath"
        }

        Write-Verbose "Checking for $PoshMTPconfigFilePath"
        If (Test-Path -Path $PoshMTPconfigFilePath -PathType Leaf){
            $ConfigSettings = @(Get-Content -Path "$PoshMTPconfigFilePath" | ConvertFrom-Json)
            $OAuthUri = $ConfigSettings.API_MDATP.OAuthUri
            $ClientID = $ConfigSettings.API_MDATP.ClientID
            $ClientSecret = $ConfigSettings.API_MDATP.ClientSecret
        }
        Else{
            Write-Error "$PoshMTPconfigFilePath not found"
            Break
        }

        # End Get API Information

        # Connect with MDATP API
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Body = @{
            resource      = "https://api.securitycenter.windows.com"
            client_id     = $ClientID
            client_secret = $ClientSecret
            grant_type    = 'client_credentials'
            redirectUri   = "https://localhost:8000"
        }
        $Response = Invoke-RestMethod -Method Post -Uri $OAuthUri -Body $Body
        #$Authorization = Invoke-RestMethod -Method Post -Uri $OAuthUri -Body $Body -ContentType "application/x-www-form-urlencoded" -UseBasicParsing
        #$access_token = $Authorization.access_token

        $headers = @{
            'Content-Type' = 'application/json'
            Accept         = 'application/json'
            Authorization  = "Bearer $($Response.access_token)"
        }
    }
    Process{
        $MDATP_API_URI = "https://api.securitycenter.windows.com/api"
        # Get the MDATP devices
        $MachineAPI = "$MDATP_API_URI/machines"
        $Machines = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json)

        If ($DeviceName){
            # change the devicename to lowercase
            $DeviceName = $DeviceName.ToLower()
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.computerDnsName -like "$DeviceName"})
        }
        Elseif ($DeviceID){
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.id -like "$DeviceID"})
        }
        Elseif($All){
            $ActionDevice = @($machines.value)
        }

        If($ActionDevice.Count -gt 0 -and $All -eq $true){
            $Result = ForEach($device in $ActionDevice){
                [PSCustomObject]@{
                    DeviceName  = $device.ComputerDnsName
                    id          = $device.id
                    machineTags = $device.machineTags
                }
            }
            $Result
        }
        ElseIf($ActionDevice.count -gt 1){
            Write-Warning "There are multiple device records with this computername, please specify the MDATP device id"
            $ActionDevice | Select-Object computerDnsName, id
            Break
        }
        Elseif($ActionDevice.count -eq 0){
            Write-Warning "No device records found that match DeviceName $DeviceName"
            Break
        }
        Elseif($ActionDevice.count -eq 1){
            $Result = [PSCustomObject]@{
                DeviceName  = $ActionDevice.ComputerDnsName
                id          = $ActionDevice.id
                machineTags = $ActionDevice.machineTags
            }
            $Result
        }
    }
    End{}
}