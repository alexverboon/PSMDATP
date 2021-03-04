function Get-MDATPDevice{
    <#
    .SYNOPSIS
    Get-MDATPDevice

    .DESCRIPTION
    Get-MDATPDevice retrieves MDATP device information

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER All
    Lists machine actions for all managed devices

    .PARAMETER HealthStatus
    Filters the results by device heatlh.

    .PARAMETER RiskScore
    Filters the results by device risk score

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder


    .EXAMPLE
    Get-MDATPDevice -all

    This command retrieves all MDATP devices

    .EXAMPLE
    Get-MDATPDevice -All -HealthStatus Inactive

    This command lists all inactive devices

    .EXAMPLE
    Get-MDATPDevice -All -RiskScore Medium

    This command lists all devices with a medium risk score

    .EXAMPLE

    Get-MDATPDevice -DeviceName Computer01

    This command retrieves device information for Computer01

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  14.04.2020
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

        # The HealthStatus of the device
        [Parameter(Mandatory=$false,
            ParameterSetName='All')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Inactive','Active')]
        [String]$HealthStatus,

        # The device Risk Score
        [Parameter(Mandatory=$false,
            ParameterSetName='All')]
        [ValidateSet('None','Low','Medium','High')]
        [String]$RiskScore,

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
        $headers = @{
            'Content-Type' = 'application/json'
            Accept         = 'application/json'
            Authorization  = "Bearer $($Response.access_token)"
        }
    }
    Process{
        $DeviceUri = "https://api.securitycenter.windows.com/api/machines"

        If($PSBoundParameters.ContainsKey("HealthStatus")){
            $HealthFilter = "healthStatus eq '$Healthstatus'"
        }

        If($PSBoundParameters.ContainsKey("RiskScore")){
            $RiskFilter = "riskscore eq '$RiskScore'"
        }

        If ($HealthFilter -and $RiskFilter){
            $DeviceUri = $DeviceUri + "?`$filter=" + $HealthFilter + " and " + $RiskFilter
        }
        Elseif($HealthFilter){
            $DeviceUri = $DeviceUri + "?`$filter=" + $HealthFilter
        }
        ElseIf ($RiskFilter){
            $DeviceUri = $DeviceUri + "?`$filter="+$RiskFilter
        }


        If ($PSBoundParameters.ContainsKey("DeviceName")){
            $DeviceUri = $DeviceUri +  "?`$filter=" + "ComputerDNSName eq '$DeviceName'"
        }

        If ($PSBoundParameters.ContainsKey("DeviceID")){
            $DeviceUri = $DeviceUri +  "?`$filter=" + "id eq '$DeviceID'"
        }

        Write-Verbose "API Request: $DeviceUri"
        Try{
            $DeviceList = @(Invoke-RestMethod -Uri "$DeviceUri" -Headers $Headers -Method Get -Verbose -ContentType application/json)
            $Devicelist.value
        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP device data [$errorMessage]"
        }
    }
    End{
    }
}

