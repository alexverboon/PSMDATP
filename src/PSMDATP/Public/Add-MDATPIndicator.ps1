function Add-MDATPIndicator{
    <#
    .Synopsis
    Add-MDATPIndicator

    .DESCRIPTION
    Add-MDATPIndicator Submits or Updates new Indicator entity.

    .PARAMETER IndicatorValue
    Identity of the Indicator entity. Required

    .PARAMETER IndicatorType
    Type of the indicator. Possible values are: "FileSha1", "FileSha256", "IpAddress", "DomainName" and "Url". Required

    .PARAMETER Action
    The action that will be taken if the indicator will be discovered in the organization. Possible values are: "Alert", "AlertAndBlock", and "Allowed". Required

    .PARAMETER Application
    The application associated with the indicator. Optional

    .PARAMETER Title
    Indicator alert title. Required

    .PARAMETER Description
    Description of the indicator. Required

    .PARAMETER expirationTime
    The expiration time of the indicator. Optional

    .PARAMETER Severity
    The severity of the indicator. possible values are: "Informational", "Low", "Medium" and "High". Optional

    .PARAMETER recommendedActions
    TI indicator alert recommended actions. Optional

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Add-MDATPIndicator -IndicatorValue "https://www.sample.com" -IndicatorType Url -Action Alert -Title "Sample URL detected" -Description "Access to the website sample.com detected" -severity High

    This command adds the URL indicator for https://www.sample.com

    .EXAMPLE

    Add-MDATPIndicator -IndicatorType DomainName www.somedomain.com -Action Alert -Title "somedomain domain detected" -Description "somedomain domain detected from custom indicator" -severity Informational

    This command ads the domain indicator for www.somedomain.com

    .EXAMPLE
    Add-MDATPIndicator -IndicatorValue "A4B52BBC94F10572296D3F8F4E25B39A1837D00F3036955C3761A9E7B2207A58" -IndicatorType FileSha256 -Action Alert -Title "Dummy File" -severity Informational -Description "dummy file detected"

    This command creates FileSha256 indicator

    .EXAMPLE
    Add-MDATPIndicator -IndicatorType IpAddress -IndicatorValue 138.223.70.10 -Action Alert -Title "IP Address indicator 138.223.70.10" -Description "access detected" -severity Medium

    This command adds an IP indicator

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  05.05.2020
    Purpose/Change: Initial script development

    #>
    [CmdletBinding(SupportsShouldProcess)]
    Param(

        # The value of the indicator
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$IndicatorValue,

        # The type of the indicator
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('DomainName','Url','FileSha256','IpAddress')]
        [String]$IndicatorType,

        # The Action taken
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [ValidateSet('Alert','AlertAndBlock','Block')]
        [String]$Action,

        # associated application
        [Parameter(Mandatory=$false)]
        [String]$Application,

        # Alert Title
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$Title,

        # Alert Description
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]$Description,

        # Alert expirationTime
        [Parameter(Mandatory=$false)]
        [ValidateNotNullorEmpty()]
        [String]$expirationTime,

        # Alert Severity
        [Parameter(Mandatory=$true)]
        [ValidateSet('Informational','Low','Medium','High')]
        [String]$severity,

        # Alert recommendedActions
        [Parameter(Mandatory=$false)]
        [String]$recommendedActions,

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
            # If no configfile is defined we use a defined lcoation .\Config\PoshMTPconfig.json
            $ConfigFileDir =  [IO.Directory]::GetParent($PSScriptRoot)
            $PoshMTPconfigFilePath = "$ConfigFileDir\" +  "PoshMTPconfig.json"
            Write-Verbose "MTP ConfigFile static: $PoshMTPconfigFilePath"
        }

        Write-Verbose "Checking for $PoshMTPconfigFilePath"
        If (Test-Path -Path "$PoshMTPconfigFilePath" -PathType Leaf ){
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
        $indicatorsuri = "https://api.securitycenter.windows.com/api/indicators"

        $AddIndicator = @{
            "indicatorValue"     = "$IndicatorValue";
            "indicatorType"      = "$IndicatorType";
            "action"             = "$Action";
            "application"        = "$Application";
            "title"              = "$Title";
            "description"        = "$Description";
            "expirationTime"     = "$expirationTime";
            "severity"           = "$severity";
            "recommendedActions" = "$recommendedActions"
        }

        If ([string]::IsNullOrEmpty($application)){
            $AddIndicator.Remove('application')
        }

        If ([string]::IsNullOrEmpty($recommendedActions)){
            $AddIndicator.Remove('recommendedActions')
        }

        If ([string]::IsNullOrEmpty($expirationTime)){
            $AddIndicator.Remove('expirationTime')
        }

        $AddIndicator = $AddIndicator | ConvertTo-Json
        Write-Verbose "Request body: $AddIndicator"

        if ($pscmdlet.ShouldProcess("$IndicatorValue", "Adding Indicator: $IndicatorType")){
            Try{
                $response = Invoke-WebRequest -Uri $indicatorsuri -Headers $Headers -Method Post -Body $AddIndicator
                If ($response.StatusCode -eq 200){
                    Write-Verbose "Indicator: $IndicatorType -  $IndicatorValue was successfully added "
                    $True
                }
                Else{
                    Write-Warning "Adding Indicator: $IndicatorType -  $IndicatorValue failed "
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
        Write-Verbose "IndicatorType: $IndicatorType"
        Write-Verbose "IndicatorValue: $IndicatorValue"
        Write-Verbose "Severity; $Severity"
        Write-Verbose "StatusCode: $($response.statuscode)"
        Write-Verbose "StatusDescription: $($response.StatusDescription)"
    }
}