function Get-MDATPInvestigation{
    <#
    .Synopsis
    Get-MDATPInvestigation

    .DESCRIPTION
    Get-MDATPInvestigation retrieves Microsoft Defender ATP automated investigation information

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER id
    The investigation id

    .PARAMETER State
    The current state of the investigation. Possible values are:
    Unknown, Terminated, SuccessfullyRemediated, Benign, Failed, PartiallyRemediated, Running, PendingApproval, PendingResource, PartiallyInvestigated, TerminatedByUser, TerminatedBySystem, Queued, InnerFailure, PreexistingAlert, UnsupportedOs, UnsupportedAlertType, SuppressedAlert

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Get-MDATPInvestigation

    This command retrieves all investigations

    .EXAMPLE
    Get-MDATPInvestigation -DeviceName Computer01

    This command retrieves all investigations for Computer01

    .EXAMPLE
    Get-MDATPInvestigation -DeviceID 70077ccc272ab3baeb991c09442c5657d22bfc5c

    This command retrieves all investigations for the device with the specified
    device id.

    .EXAMPLE
    Get-MDATPInvestigation -State Running

    This command retireves all investigations with the state Running

    .EXAMPLE
    Get-MDATPInvestigation -Id 12

    This command retrieves investigation details for the investigation with id 12

    .EXAMPLE
    Get-MDATPInvestigation -DeviceName computer01 -State SuccessfullyRemediated

    This command retrieves all SuccessfullyRemediated investigations for device computer01

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  12.04.2020
    Purpose/Change: Initial script development
    #>
    [CmdletBinding(DefaultParametersetname="All")]
    Param(
        # Switch to list all devices
        [Parameter(Mandatory=$false,
            ParameterSetName='All')]
        [ValidateNotNullOrEmpty()]
        [switch]$All,

        # Computername of the MDATP managed device
        [Parameter(Mandatory=$false,
            ParameterSetName='DeviceName')]
        [ValidateNotNullOrEmpty()]
        [String]$DeviceName,

        # Unique device id of the MDATP managed device
        [Parameter(Mandatory=$false,
            ParameterSetName='DeviceID')]
        [ValidateNotNullOrEmpty()]
        [String]$DeviceID,

        # MDATP investigation id
        [Parameter(Mandatory=$false,
            ParameterSetName='id')]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        # Investigation state
        [Parameter(Mandatory=$false)]
        [ValidateSet(  'Unknown','Terminated','SuccessfullyRemediated','Benign','Failed','PartiallyRemediated','Running','PendingApproval','PendingResource','PartiallyInvestigated','TerminatedByUser','TerminatedBySystem','Queued','InnerFailure','PreexistingAlert','UnsupportedOs','UnsupportedAlertType','SuppressedAlert')]
        [String]$State,

        # API Configuration file
        [Parameter(Mandatory=$false)]
        [String]$MTPConfigFile
    )

    Begin{
        # Begin Get API access configuration
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
            $ConfigSettings  = @(Get-Content -Path "$PoshMTPconfigFilePath" | ConvertFrom-Json)
            $OAuthUri        = $ConfigSettings.API_MDATP.OAuthUri
            $ClientID        = $ConfigSettings.API_MDATP.ClientID
            $ClientSecret    = $ConfigSettings.API_MDATP.ClientSecret
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
            $MachineAPI = "https://api.securitycenter.windows.com/api/machines"
            $DeviceName = $DeviceName.ToLower()
            $Machines = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json)
            $ActionDevice = @($machines.value | Select-Object -Property *  | Where-Object {$_.computerDnsName -like "$DeviceName"})

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

        # Get Investigation data
        $InvestigationUri= "https://api-us.securitycenter.windows.com/api/investigations/"
        if($PSBoundParameters.ContainsKey("All")){
            $InvestigationUri= "https://api-us.securitycenter.windows.com/api/investigations/"
        }
        Else{
            If($DeviceName){
                $InvestigationUri = $InvestigationUri + "?`$filter="
                $InvestigationUri = $InvestigationUri + "machineId+eq+'$DeviceID'"
            }

            If($State){
                If($DeviceName){
                    $InvestigationUri = $InvestigationUri + "and state+eq+'$State'"
                }
                Else{
                    $InvestigationUri = $InvestigationUri + "?`$filter="
                    $InvestigationUri = $InvestigationUri + "state+eq+'$State'"
                }
            }

            # Search by Investigation ID
            if($id){
                $InvestigationUri = $InvestigationUri + "$id"
            }
        }
        # Retrieve MDATP Investigations data
        Try{
            $output = @(Invoke-RestMethod -Uri $InvestigationUri -Headers $Headers -Method Get -Verbose -ContentType application/json)
        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP inestigation data [$errorMessage]"
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