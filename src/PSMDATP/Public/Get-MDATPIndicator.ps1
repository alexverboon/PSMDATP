function Get-MDATPIndicator{
    <#
    .Synopsis
    Get-MDATPIndicator

    .DESCRIPTION
    Get-MDATPIndicator retrieves Microsoft Defender Advanced Threat Protection custom indicators exposed
    through the Microsoft Defender Advanced Threat Protection indicators Rest API.

    .PARAMETER IndicatorType
    Filters the indicator by the specified IndicatorType. Possible values are: DomainName, Url, FileSha256,IpAddress,WebCategory

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Get-MDATPIndicator

    This command retrieves all TI indicators

    .EXAMPLE
    Get-MDATPIndicator -IndicatorType DomainName

    This command retrieves all DomainName TI indicators

    .EXAMPLE
        $indicators = Get-MDATPIndicator -MTPConfigFile "C:\Dev\Private\MSSecurityPowerShell\Config\PoshMTPconfigBaseVISION.json"
        $indicators | Where-Object {$_.Source -like "WindowsDefenderATPThreatIntelAPI"}

        This sample shows how to filter results by TI source

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  20.03.2020
    Purpose/Change: Initial script development
    #>
    [CmdletBinding()]
    Param(
        # Indicator type
        [Parameter(Mandatory=$false)]
        [ValidateSet('DomainName','Url','FileSha256','IpAddress','WebCategory')]
        [String]$IndicatorType,

        # MDATP configfile
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
        Try{
            $indicatorsuri = "https://api.securitycenter.windows.com/api/indicators"
            $indicators = @(Invoke-RestMethod -Uri $indicatorsuri -Headers $Headers -Body $Body -Method Get -Verbose -ContentType application/json)

        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP TI indicators data [$errorMessage]"
        }

        If ($IndicatorType){
            $indicators.value | Where-Object {$_.IndicatorType -eq "$IndicatorType"}
        }
        Else{
            $indicators.value
        }
    }
    End{}
}