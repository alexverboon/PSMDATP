function Remove-MDATPDeviceTag{
    <#
    .Synopsis
    Remove-MDATPDeviceTag

    .Description
    Remove-MDATPDeviceTag removes the specified Tag to the MDATP device.

    .PARAMETER DeviceName
    Computername of the device

    .PARAMETER DeviceID
    The unique device ID of the device

    .PARAMETER Tag
    The value of the tag to be removed

    .PARAMETER MTPConfigFile
    The MTPConfigFile contains the API connection information, if not specified a default PoshMTPconfig.json  is used that must be located in the module folder


    .EXAMPLE
    Remove-MDATPDeviceTag -DeviceName computer02 -Tag 'Testing' -verbose

    This command removes the tag 'testing' from device 'computer02'

    .NOTES
    Version:        1.0
    Author:         Alex Verboon
    Creation Date:  16.03.2020
    Purpose/Change: Initial script development
    #>

    [CmdletBinding(SupportsShouldProcess)]
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

        # Tag to be removed from the device
        [Parameter(Mandatory=$true)]
        [String]$Tag,

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
        If (Test-Path -Path $PoshMTPconfigFilePath -PathType Leaf){
            $ConfigSettings     = @(Get-Content -Path "$PoshMTPconfigFilePath" | ConvertFrom-Json)
            $OAuthUri           = $ConfigSettings.API_MDATP.OAuthUri
            $ClientID           = $ConfigSettings.API_MDATP.ClientID
            $ClientSecret       = $ConfigSettings.API_MDATP.ClientSecret
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
        # MDATP API URI
        $MDATP_API_URI = "https://api.securitycenter.windows.com/api"

        # change the devicename to lowercase
        $DeviceName = $DeviceName.ToLower()

        # Get the MDATP devices
        $MachineAPI = "$MDATP_API_URI/machines"
        $Machines = @(Invoke-RestMethod -Uri "$MachineAPI" -Headers $Headers -Method Get -Verbose -ContentType application/json)
        If ($DeviceName){
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.computerDnsName -like "$DeviceName"})
        }
        Elseif ($DeviceID){
            $ActionDevice = @($machines.value | Select-Object * | Where-Object {$_.id -like "$DeviceID"})
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
            $MDATPDeviceID = $ActionDevice.id
            if ($pscmdlet.ShouldProcess("$DeviceName", "Remvoing tag: $Tag")){
                Try{
                    # Tag machine
                    $AddTag = @{"Value" = "$Tag"; "Action"= "Remove"} | ConvertTo-Json
                    $Taguri = "$MachineAPI/$MDATPDeviceID/tags"
                    $response  =Invoke-WebRequest -Uri $Taguri -Headers $Headers -Method Post -Body $AddTag
                    # end tag machine
                    If ($response.StatusCode -eq 200){
                        Write-Verbose "Tag: $Tag was successfully removed from device $DeviceName"
                        $True
                    }
                    Else{
                        Write-Warning "Removing tag $Tag from device $DeviceName failed!"
                        Write-Error "StatusCode: $($response.StatusCode)"
                        $false
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
    }
    End{
        Write-Verbose "Device: $DeviceName"
        Write-Verbose "DeviceID: $MDATPDeviceID"
        Write-Verbose "Removed tag: $Tag"
        Write-Verbose "StatusCode: $($response.statuscode)"
        Write-Verbose "StatusDescription: $($response.StatusDescription)"
    }
}