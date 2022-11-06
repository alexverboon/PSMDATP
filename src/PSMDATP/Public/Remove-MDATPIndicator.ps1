function Remove-MDATPIndicator{
    <#
    .Synopsis
    Remove-MDATPIndicator

    .DESCRIPTION
    Remove-MDATPIndicator removes a custom indicator from the Microsoft Defender ATP 
    instance
        
    .PARAMETER IndicatorID
    The unique custom indicator ID
    
    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Remove-MDATPIndicator -IndicatorID 25

    This command removes the custom indicator with id 25
    
    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  05.05.2020
    Purpose/Change: Initial script development

    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        # Unique custom indicator ID
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,150000)]
        [int]$IndicatorID,

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
            $ConfigSettings   = @(Get-Content -Path "$PoshMTPconfigFilePath" | ConvertFrom-Json)
            $OAuthUri         = $ConfigSettings.API_MDATP.OAuthUri
            $ClientID         = $ConfigSettings.API_MDATP.ClientID
            $ClientSecret     = $ConfigSettings.API_MDATP.ClientSecret
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
        Try{
            $indicatorsuri = "https://api.securitycenter.windows.com/api/indicators"
            $indicators = @(Invoke-RestMethod -Uri $indicatorsuri -Headers $Headers -Body $Body -Method Get -ContentType application/json)
        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP TI indicators data [$errorMessage]"
        }

        $IndicatorInfo = $indicators.value | Where-Object {$_.id -eq $IndicatorID}
        $RemoveIndicatorsuri = "https://api.securitycenter.windows.com/api/indicators/$IndicatorID"

        if ($pscmdlet.ShouldProcess("$IndicatorID", "Remvoing Indicator - $($IndicatorInfo.IndicatorType) - $($IndicatorInfo.indicatorvalue)")){
            Try{
                $response = Invoke-WebRequest -Uri $RemoveIndicatorsuri -Headers $Headers -Method Delete
                If ($response.StatusCode -eq 204){
                    Write-Verbose "Indicator: $IndicatorID - $($IndicatorInfo.IndicatorType) - $($IndicatorInfo.indicatorvalue) was successfully removed"
                    $True
                }
                Else{
                    Write-Warning "Removing Indicator: $IndicatorID failed"
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
        Write-Verbose "IndicatorID: $IndicatorID"
        Write-Verbose "IndicatorType: $($IndicatorInfo.indicatorType)"
        Write-Verbose "Indicatorvalue: $($IndicatorInfo.indicatorValue)"
        Write-Verbose "StatusCode: $($response.statuscode)"
        Write-Verbose "StatusDescription: $($response.StatusDescription)"
    }
}