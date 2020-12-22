function Get-MDATPEndpointStatus{
    <#
    .Synopsis
    Get-MDATPEndpointStatus

    .DESCRIPTION
    Get-MDATPEndpointStatus retrieves information about the Endpoint Status

    https://github.com/microsoft/Microsoft-365-Defender-Hunting-Queries/blob/master/General%20queries/Endpoint%20Agent%20Health%20Status%20Report.md

    This query will provide a report of many of the best practice configurations for Defender ATP deployment. Special Thanks to Gilad Mittelman for the initial inspiration and concept.
    Any tests which are reporting "BAD" as a result imply that the associated capability is not configured per best practice recommendation.

    Limitations
    1. The results will include a maximum of 100,000 rows.
    2. The number of executions is limited per tenant: up to 15 calls per minute, 15 minutes of running time every hour and 4 hours of running time a day.
    3. The maximal execution time of a single request is 10 minutes.

    .PARAMETER DeviceName
    Computername of the device.If no DeviceName is provided all devices are querried

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Get-MDATPEndpointStatus -DeviceName TestClient4

    .EXAMPLE
    Get-MDATPEndpointStatus


    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  22.12.2020
    Purpose/Change: Initial script development

    #>
    [CmdletBinding()]
    Param
    (
        # Computername of the MDATP managed device
        [Parameter(Mandatory=$false)]
        [String]$DeviceName,

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
            $OAuthUri       = $ConfigSettings.API_MDATP.OAuthUri
            $ClientID       = $ConfigSettings.API_MDATP.ClientID
            $ClientSecret   = $ConfigSettings.API_MDATP.ClientSecret
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
$kqlquery = @"
// Best practice endpoint configurations for Microsoft Defender for Endpoint deployment.
DeviceTvmSecureConfigurationAssessment
//DEVICENAME
| where ConfigurationId in ("scid-91", "scid-2000", "scid-2001", "scid-2002", "scid-2003", "scid-2010", "scid-2011", "scid-2012", "scid-2013", "scid-2014", "scid-2016")
| summarize arg_max(Timestamp, IsCompliant, IsApplicable) by DeviceId, DeviceName, ConfigurationId
| extend Test = case(
    ConfigurationId == "scid-2000", "SensorEnabled",
    ConfigurationId == "scid-2001", "SensorDataCollection",
    ConfigurationId == "scid-2002", "ImpairedCommunications",
    ConfigurationId == "scid-2003", "TamperProtection",
    ConfigurationId == "scid-2010", "AntivirusEnabled",
    ConfigurationId == "scid-2011", "AntivirusSignatureVersion",
    ConfigurationId == "scid-2012", "RealtimeProtection",
    ConfigurationId == "scid-91", "BehaviorMonitoring",
    ConfigurationId == "scid-2013", "PUAProtection",
    ConfigurationId == "scid-2014", "AntivirusReporting",
    ConfigurationId == "scid-2016", "CloudProtection",
    "N/A"),
    Result = case(IsApplicable == 0, "N/A", IsCompliant == 1, "GOOD", "BAD")
| extend packed = pack(Test, Result)
| summarize Tests = make_bag(packed) by DeviceId, DeviceName
| evaluate bag_unpack(Tests)
"@



        If ([string]::IsNullOrEmpty($DeviceName)){
            # nothing to do , we run the query against all devices
        }
        Else{
            $DeviceName = $DeviceName.ToLower()
            $replacestring = "| where DeviceName == '$DeviceName'"
            $kqlquery = $kqlquery.Replace("//DEVICENAME","$replacestring")
        }
        $uri = "https://api.securitycenter.windows.com/api/advancedqueries/run"
        $body = ConvertTo-Json -InputObject @{ 'Query' = $kqlquery}
        Try{
            $webResponse = @(Invoke-WebRequest -Method Post -Uri $uri -Headers $headers -Body $body)
            $response =  $webResponse | ConvertFrom-Json
            $results = $response.Results
            $results
        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error running advanced hunting query [$errorMessage]"
        }
    }
    End{
        Write-Verbose "Schema: $Schema"
        Write-Verbose "Device: $DeviceTarget"
        Write-Verbose "Query: $ExecQuery"
        Write-Verbose "Retrieved $($results.count) records"
    }
}