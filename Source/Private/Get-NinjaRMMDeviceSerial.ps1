<#
.SYNOPSIS
    Fetches device serial number from NinjaRMM.
.PARAMETER AccessToken
    Security.SecureString - The OAuth 2.0 Access Token.
.PARAMETER DeviceID
    Int - The ID of the device in NinjaRMM.
.EXAMPLE
    Get-NinjaRMMDeviceSerial -AccessToken $AccessToken -DeviceID 1
    System Serial Number
.OUTPUTS
    Get-NinjaRMMDevice returns the serial number of the specified device as a string.
.NOTES
    For more information on this API call, see: https://app.ninjarmm.com/apidocs/?links.active=core#/devices/getDevice
#>
function Get-NinjaRMMDeviceSerial {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Security.SecureString]
        $AccessToken,

        [Parameter(Mandatory)]
        [int]
        $DeviceID
    )

    try {
        $Device = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/device/$($DeviceID)" -Authentication OAuth -Token $AccessToken | Select-Object -ExpandProperty system | Select-Object -ExpandProperty biosSerialNumber
    }
    catch {
        Write-Error -Message "Error fetching device from the NinjaRMM API."
    }

    return $Device
}

#Get-NinjaRMMDeviceSerial -AccessToken $AccessToken -DeviceID 1