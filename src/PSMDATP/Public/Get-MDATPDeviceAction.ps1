function Get-MDATPDeviceAction{
    <#
    .Synopsis
    Get-MDATPDeviceAction

    .DESCRIPTION
    Get-MDATPDeviceAction retrieves machine MDATP actions

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER All
    Lists machine actions for all managed devices

    .PARAMETER Action Type
    Filters the results by the specified Action type. Possible values are: RunAntiVirusScan, Offboard,UnrestrictCodeExecution,RestrictCodeExecution,Unisolate,Isolate,CollectInvestigationPackage,RequestSample,StopAndQuarantineFile

    .PARAMETER id
    The machine action id

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
        Get-MDATPDeviceAction -DeviceName computer02

        This command retrieves the actions for device 'computer02'

    .EXAMPLE
        Get-MDATPDeviceAction -DeviceID 70077ccc272ab3baeb991c09442c5657d22bfc5c

        This command retrieves the actions for the device with the specified device id

    .EXAMPLE
        Get-MDATPDeviceAction -ActionType CollectInvestigationPackage

        This command retreives all machine actions with the specified action type

    .EXAMPLE
        Get-MDATPDeviceAction -All

        This command retrieves machine actions for all devices


    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  12.04.2020
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

        # Switch to retrieve actions from all devices
        [Parameter(Mandatory=$true,
            ParameterSetName='All')]
        [switch]$All,

        # MDATP Action id
        [Parameter(Mandatory=$false,
            ParameterSetName='id')]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        # Action Type
        [Parameter(Mandatory=$false)]
        [ValidateSet('RunAntiVirusScan','Offboard','UnrestrictCodeExecution','RestrictCodeExecution','Unisolate','Isolate','CollectInvestigationPackage','RequestSample','StopAndQuarantineFile')]
        [String]$ActionType,

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

        If ($DeviceName){
            $Machines = @()
            $DeviceName = $DeviceName.ToLower()
            $MachineAPI = "https://api.securitycenter.windows.com/api/machines" + "?`$filter=" + "ComputerDNSName eq '$DeviceName'"
            $Machines = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json) | Select-Object -ExpandProperty Value
            $ActionDevice = @($Machines)

            If($ActionDevice.count -gt 1){
                Write-Error "There are multiple device records with this computername, please specify the MDATP device id"
                $ActionDevice | Select-Object computerDnsName, id
            }
            Elseif($ActionDevice.count -eq 0){
                Write-Error "No device records found that match DeviceName $DeviceName"
            }
            Elseif ($ActionDevice.count -eq 1){
                Write-Verbose "$($ActionDevice.CompueterDnsName) found with id $($ActionDevice.id)"
                $DeviceID = $ActionDevice.id
            }
            Else{
                Write-Error "Something went wrong"
            }
        }


        if($DeviceID){
            $MachineAPI = "https://api.securitycenter.windows.com/api/machines/$DeviceID"
            $Machine = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json)
            If($Machine.Count -eq 1){
                $DeviceName = $Machine.ComputerDnsName
            }
            Else{
                Write-Error "No device records found that match DeviceID $DeviceID"
            }
        }

        # Get Machine Actions data
        $MachineActionsUri= "https://api-us.securitycenter.windows.com/api/machineactions/"
        if($PSBoundParameters.ContainsKey("All")){
            $MachineActionsUri= "https://api-us.securitycenter.windows.com/api/machineactions/"
        }
        Else{
            If($DeviceName){
                $MachineActionsUri = $MachineActionsUri + "?`$filter="
                $MachineActionsUri = $MachineActionsUri + "machineId+eq+'$DeviceID'"
            }

            If($ActionType){
                If($DeviceName){
                    $MachineActionsUri = $MachineActionsUri + "and type+eq+'$ActionType'"
                }
                Else{
                    $MachineActionsUri = $MachineActionsUri + "?`$filter="
                    $MachineActionsUri = $MachineActionsUri + "type+eq+'$ActionType'"
                }
            }
            # Search by action ID
            if($id){
                $MachineActionsUri = $MachineActionsUri + "$id"
            }
        }

        # Retrieve MDATP machine actions data
        Try{
            $output = @(Invoke-RestMethod -Uri $MachineActionsUri -Headers $Headers -Method Get -Verbose -ContentType application/json)
        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP machine actions data [$errorMessage]"
        }

        # Handle the output
        If($id){
            $output
        }
        Else{
            $output.value
        }
    }
    End{}
}