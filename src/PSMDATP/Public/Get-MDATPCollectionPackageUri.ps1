function Get-MDATPCollectionPackageUri{
    <#
    .Synopsis
    Get-MDATPCollectionPackageUri

    .DESCRIPTION
    Get-MDATPCollectionPackageUri retrieves the Investigation Collection Package download URI and optionally download the package

    Use the Get-MDATPDeviceActions cmdlet to retrieve the ActionID of the investigation package collection request.

    .PARAMETER ActionID
    The Action ID of the investigation package collection request.

    .PARAMETER Download
    Downloads the investigation pacakge ZIP file into the users Downloads folder

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE

    $lastcollectionrequestid = Get-MDATPDeviceActions -DeviceName testclient6 -ActionType CollectInvestigationPackage | Select-Object -First 1
    Get-MDATPCollectionPackageUri -ActionID $lastcollectionrequestid.id

    This comand first retrieves the last collection package request ID and then retrieves the download URI

    .EXAMPLE
    $lastcollectionrequestid = Get-MDATPDeviceActions -DeviceName testclient6 -ActionType CollectInvestigationPackage | Select-Object -First 1
    Get-MDATPCollectionPackageUri -ActionID $lastcollectionrequestid.id -Download

    This comand first retrieves the last collection package request ID and stores the investigation package into the users download folder

.COMPONENT
    <%=$PLASTER_PARAM_ModuleName%>

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  12.04.2020
    Purpose/Change: Initial script development
    #>

    [CmdletBinding()]
    Param(
        # ActionID
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$ActionID,

        # API Configuration
        [Parameter(Mandatory=$false)]
        [String]$MTPConfigFile,

        # Download switch
        [switch]$Download
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

        # MDATP API URI
        $MDATP_API_URI = "https://api.securitycenter.windows.com/api"

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
        # Define the request URI
        $MachineActionAPI = "$MDATP_API_URI/machineactions"
        $getPackageUri = "getPackageUri"
        $RequestURI = "$MachineActionAPI/$ActionID/$getPackageUri"
        Write-Verbose "Request URI: $($RequestURI)"

        # Let's get the Investigation Collection Package download URL
        Try{
            $URIresponse = @(Invoke-RestMethod -Uri "$RequestURI" -Headers $Headers -Method Get -Verbose -ContentType application/json)
            $URIresponse.value
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

        If($Download){
            $fileuri = $URIresponse.value
            $OutPutFile = "$ENV:USERPROFILE\Downloads\MDATP_InvestigationPackage_$($ActionID).zip"
            Try{
                Invoke-WebRequest -UseBasicParsing -Uri $fileuri -OutFile "$OutPutFile"
            }
            Catch{
                Write-Error "Investigation Package download failed"
            }
        }
    }
    End{}
}