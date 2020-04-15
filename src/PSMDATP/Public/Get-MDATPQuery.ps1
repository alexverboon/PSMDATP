function Get-MDATPQuery{
    <#
    .Synopsis
    Get-MDATPQuery

    .DESCRIPTION
    Get-MDATPQuery executes MDATP advanced hunting queries through the
    Microsoft Defender Advanced Threat Protection Alerts Rest API.

    Limitations
    1. You can only run a query on data from the last 30 days.
    2. The results will include a maximum of 100,000 rows.
    3. The number of executions is limited per tenant: up to 15 calls per minute, 15 minutes of running time every hour and 4 hours of running time a day.
    4. The maximal execution time of a single request is 10 minutes.

    .PARAMETER Schema
    The Schema to use for the query

    .PARAMETER DeviceName
    Computername of the device.If no DeviceName is provided all devices are querried

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Get-MDATPQuery -Schema DeviceLogonEvents -DeviceName TestClient4

    The above query retrieves all logon events for the specified device

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  17.02.2020
    Purpose/Change: Initial script development

    #>
    [CmdletBinding()]
    Param
    (
        # The MDATP Schema to search for
        [Parameter(Mandatory=$true)]
        [ValidateSet('DeviceAlertEvents','DeviceInfo','DeviceNetworkInfo','DeviceProcessEvents','DeviceFileEvents','DeviceRegistryEvents','DeviceLogonEvents','DeviceImageLoadEvents','DeviceEvents')]
        [String]$Schema,

        # Computername of the MDATP managed device
        [Parameter(Mandatory=$false)]
        [String]$DeviceName,

        # The Time Range
        [Parameter(Mandatory=$false)]
        [ValidateSet('1h', '12h', '1d','7d','30d')]
        [String]$TimeRange,

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
        #$Authorization = Invoke-RestMethod -Method Post -Uri $OAuthUri -Body $Body -ContentType "application/x-www-form-urlencoded" -UseBasicParsing
        #$access_token = $Authorization.access_token

        $headers = @{
            'Content-Type' = 'application/json'
            Accept         = 'application/json'
            Authorization  = "Bearer $($Response.access_token)"
        }
    }
    Process{
        #WDATP API
        $uri = "https://api.securitycenter.windows.com/api/advancedqueries/run"
        # Define devices to include in query
        if ($DeviceName){
            $DeviceName = $DeviceName.ToLower()
            $ExecQuery = "$Schema | where DeviceName == '$DeviceName'"
        }
        Else{
            $ExecQuery = "$Schema"
        }
        $DeviceTarget = if([string]::IsNullOrEmpty($DeviceName)) {"All Devices"}Else {"$DeviceName"}

        If ($TimeRange){
            $ExecQuery = $ExecQuery + "|where Timestamp > ago($($TimeRange))"
        }


        Try{
            $body = ConvertTo-Json -InputObject @{ 'Query' = $ExecQuery}
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