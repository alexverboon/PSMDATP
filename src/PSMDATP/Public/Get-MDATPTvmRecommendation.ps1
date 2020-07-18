function Get-MDATPTvmRecommendation{
    <#
    .Synopsis
    Get-MDATPTvmRecommendation

    .DESCRIPTION
    Get-MDATPTvmRecommendation retrieves Microsoft Defender Advanced Threat Protection Threat and Vulnerability Management
    security recommendations

    .PARAMETER recommendationCategory
    
    Category or grouping to which the configuration belongs: Application, OS, Network, Accounts, Security controls
    
    .PARAMETER publicexploit

    Setting this parameter limits the results to security recommendations that address a public exploit

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder

    .EXAMPLE
    Get-MDATPTvmRecommendation

    This command retrieves all TVM security recommendations

    .EXAMPLE
        $tvmrecommendations = Get-MDATPTvmRecommendation -MTPConfigFile "C:\Users\Alex\Documents\WindowsPowerShell\Modules\PSMDATP\PoshMTPconfig.json"
        

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  18.07.2020
    Purpose/Change: Initial script development
    #>
    [CmdletBinding()]
    Param(
        # recommendation Category 
        [Parameter(Mandatory=$false)]
        [ValidateSet('DomainName','Application','OS','Network','Accounts','Security controls')]
        [String]$recommendationCategory,


        # publicexploit
        [Parameter(Mandatory=$false)]
        [switch]$publicexploit,

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

        $headers = @{
            'Content-Type' = 'application/json'
            Accept         = 'application/json'
            Authorization  = "Bearer $($Response.access_token)"
        }
    }
    Process{
        Try{
            $tvmuri = "https://api.securitycenter.windows.com/api/recommendations"
            $tvmrecommendations = @(Invoke-RestMethod -Uri $tvmuri -Headers $Headers -Body $Body -Method Get -Verbose -ContentType application/json)

        }
        Catch{
            $errorMessage = $_.Exception.Message
            Write-Error "Error retrieving MDATP TVM security recommendations data [$errorMessage]"
        }
        
        If ($recommendationCategory){
            $Result = $tvmrecommendations.value | Where-Object {$_.recommendationCategory -eq "$recommendationCategory"}
        }
        Else{
            $Result = $tvmrecommendations.value
        }

        If ($publicexploit){
            $Result = $Result | Where-Object {$_.publicExploit -eq $true}
        }

        $Result


    }
    End{}
}