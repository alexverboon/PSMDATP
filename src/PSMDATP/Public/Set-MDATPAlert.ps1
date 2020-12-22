function Set-MDATPAlert{
    <#
    .Synopsis
    Set-MDATPAlert

    .Description
    Set-MDATPAlert updates a Microsoft Defender Advanced Threat Protection alert through the Microsoft Defender Advanced Threat Protection Alerts Rest API.

    .PARAMETER AlertID
    Identity of the Indicator entity. Required
    
    .PARAMETER status
    The status that will be set for the alert in the organization. Possible values are: "New", "InProgress", and "Resolved". Optional

    .PARAMETER assignedTo
    The userid that will be set for assigned to field for the the alert in the organization. Example: secop2@contoso.com. Optional

    .PARAMETER classification
    The classification that will be set for the alert in the organization. Possible values are: "Unknown", "FalsePositive", and "TruePositive". Optional

    .PARAMETER determination
    The determination that will be set for the alert in the organization. Possible values are: "NotAvailable", "Apt", "Malware", "SecurityPersonnel", "SecurityTesting", "UnwantedSoftware", and "Other". Optional

    .PARAMETER comments
    The comment field that will be set for the the alert in the organization. Optional

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Set-WDATPAlert -AlertID 121688558380765161_2136280442 -status Resolved -assignedTo secop2@contoso.com -classification FalsePositive -determination Malware -comments "Resolve my alert and assign to secop2
    
    .NOTES
    Version:        1.0
    Author:         Daniel Lacher
    Creation Date:  02.11.2020
    Purpose/Change: Initial pass at creation of function to allow for update to MDATP Alerts via API and PSMDATP framework.

    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        # MDATP Alert ID.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$AlertID,

        # Specifies the current status of the alert. The property values are: 'New', 'InProgress' and 'Resolved'.
        [Parameter(Mandatory=$false)]
        [ValidateSet('New', 'InProgress','Resolved')]
        [String]$status,

        # Owner of the alert.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullorEmpty()]
        [String]$assignedTo,

        # Specifies the specification of the alert. The property values are: 'Unknown', 'FalsePositive', 'TruePositive'.
        [Parameter(Mandatory=$false)]
        [ValidateSet('Unknown', 'FalsePositive', 'TruePositive')]
        [String]$classification,

        # Specifies the determination of the alert. The property values are: 'NotAvailable', 'Apt', 'Malware', 'SecurityPersonnel', 'SecurityTesting', 'UnwantedSoftware', 'Other'.
        [Parameter(Mandatory=$false)]
        [ValidateSet('NotAvailable', 'Apt', 'Malware', 'SecurityPersonnel', 'SecurityTesting', 'UnwantedSoftware', 'Other')]
        [String]$determination,

        # Comment to be added to the alert.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullorEmpty()]
        [String]$comments,

        # API Configuration file
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
            # If no configfile is defined we use a defined lcoation .\PoshMTPconfig.json
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
            client_id     = "$ClientID"
            client_secret = "$ClientSecret"
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

        $alertsuri = "https://api.securitycenter.windows.com/api/alerts/$AlertID"
        $UpdateAlert = @{
            "status"         = "$status"
            "assignedTo"     = "$assignedTo"
            "classification" = "$classification"
            "determination"  = "$determination"
            "comment"        = "$comments"
        }

        $UpdateAlert = $UpdateAlert | ConvertTo-Json
        Write-Verbose "Request body: $UpdateAlert"

        if ($pscmdlet.ShouldProcess("$AlertID", "Updating Alert: $AlertID")){
            Try{
                $response = Invoke-WebRequest -Uri $alertsuri -Headers $Headers -Method Patch -Body $UpdateAlert
                If ($response.StatusCode -eq 200){
                    Write-Verbose "Alert: $AlertID -  was successfully updated "
                    $True
                }
                Else{
                    Write-Warning "Alert: $AlertID -  update failed"
                    Write-Error "StatusCode: $($response.StatusCode)"
                    $False
                }
            }
            Catch{
                $ex = $_.Exception
                $errorResponse = $ex.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($errorResponse)
                $reader.BaseStream.Position = 0
                $reader.DiscardBufferedData()
                $responseBody = $reader.ReadToEnd();
                Write-Verbose "Response content:`n$responseBody"
                Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
            }
        }
    }
    End{
        Write-Verbose "AlertID: $AlertID";
        Write-Verbose "Status: $status";
        Write-Verbose "AssignedTo:$assignedTo";
        Write-Verbose "Classification: $classification";
        Write-Verbose "Determination: $determination";
        Write-Verbose "Comments: $comments"
    }
}