function Start-MDATPIsolation{
    <#
    .Synopsis
    Start-MDATPIsolation

    .DESCRIPTION
    Start-MDATPIsolation initiates the isolation of the specified device from the network

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER IsolationType
    Type of the isolation. Allowed values are: 'Full' or 'Selective'.

    .PARAMETER Comment
    Comment that is added to the request, if no comment is provided the default commment 'submitted by automation' is used.

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Start-MDATPIsolation -DeviceName computer02 -IsolationType Full -Comment "incident1973"

    This command isolates device computer02 from the network

    .EXAMPLE
    Start-MDATPIsolation -DeviceName computer02 -IsolationType Selective -Comment "incident1973"

    This command isolates device computer02 from the network but allows communication through Outlook and Skype

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  12.04.2020
    Purpose/Change: Initial script development
    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        # Computername of the MDATP managed device
        [Parameter(Mandatory=$false)]
        [String]$DeviceName,

        # Unique device id of the MDATP managed device
        [Parameter(Mandatory=$false)]
        [String]$DeviceID,

        # IsolationType controls the type of isolation to perform
        [Parameter(Mandatory=$true)]
        [ValidateSet('Full','Selective')]
        [String]$IsolationType,

        # Comment for the request
        [Parameter(Mandatory=$false)]
        [String]$Comment,

        # API Configuration file
        [Parameter(Mandatory=$false)]
        [String]$MTPConfigFile
    )

    Begin{
        #Check if either Name or ID provided
        if (!$DeviceName -and !$DeviceID) {
            Write-Host "Please provide either the DeviceName or DeviceID parameters." -ForegroundColor Red
            Break
        }
        
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
        If([string]::IsNullOrEmpty($Comment)){
            $Comment = "submitted by automation"
        }
        $MachineAPI = "$MDATP_API_URI/machines"
        $Machines = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json)
        
        if (!$DeviceID) {
            $DeviceName = $DeviceName.ToLower()
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.computerDnsName -like "$DeviceName"})
            $MDATPDeviceID = $ActionDevice.id
        } Else {
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.id -like "$DeviceID"})
            $DeviceName = $ActionDevice.computerDnsName
        }

        If($ActionDevice.count -gt 1){
            Write-Warning "There are multiple device records with this computername, please specify the MDATP device id"
            $ActionDevice | Select-Object computerDnsName, id
            Break
        }
        Elseif($ActionDevice.count -eq 0){
            Write-Warning "No device records found that match DeviceName $DeviceName"
            Break
        }
        Elseif($ActionDevice.count -eq 1){
            if ($pscmdlet.ShouldProcess("$DeviceName", "Start Isolation: $IsolationType")){
                Try{
                    $IsolationTypeInput = @{"IsolationType" = "$IsolationType"; "Comment"= "$Comment"} | ConvertTo-Json
                    $IsolateUri = "$MachineAPI/$MDATPDeviceID/isolate"
                    $IsolateResponse  =Invoke-WebRequest -Uri $IsolateUri -Headers $Headers -Method Post -Body $IsolationTypeInput
                    If ($IsolateResponse.StatusCode -eq 201){
                        $ActionID = $IsolateResponse.content | ConvertFrom-Json | Select-Object -ExpandProperty id
                        Write-Verbose "$IsolationType isolation was successfully initiated for device $DeviceName -ActionID: $ActionID"
                        $ActionID
                    }
                    Else{
                        $ActionID = "0000000-0000-0000-0000-000000000000"
                        Write-Warning "Initiating $IsolationType isolation for device $DeviceName failed!"
                        Write-Error "StatusCode: $($IsolateResponse.StatusCode)"
                        $ActionID
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
                    $ActionID = "0000000-0000-0000-0000-000000000000"
                    $ActionID
                }
            }
        }
    }
    End{
        Write-Verbose "Device: $DeviceName"
        Write-Verbose "DeviceID: $MDATPDeviceID"
        Write-Verbose "IsolationType: $IsolationType"
        Write-Verbose "Comment: $Comment"
        Write-Verbose "ActionID: $($ActionID)"
        Write-Verbose "StatusCode: $($IsolateResponse.statuscode)"
        Write-Verbose "StatusDescription: $($IsolateResponse.StatusDescription)"
    }
}
