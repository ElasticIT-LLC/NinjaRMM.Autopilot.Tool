<#
.SYNOPSIS
    Fetches a list of devices in NinjaRMM with the Autopilot HWID custom field.
.DESCRIPTION
    This function pulls a report from NinjaRMM of all devices with the specified Autopilot HWID custom field.
.PARAMETER AccessToken
    Security.SecureString - The OAuth 2.0 Access Token.
.PARAMETER OrganizationID
    Int - The ID of the organization in NinjaRMM.
.EXAMPLE
    Get-NinjaRMMDevicesWithAutopilotField -AccessToken $AccessToken -OrganizationID 1
    DeviceID AutopilotHWID
    -------- -------------
           1 Q0HjAgEAHAAAA123AfwRhSgAACgBWB7FKX6OzKPA...
.OUTPUTS
    Get-NinjaRMMDevicesWithAutopilotField returns a list of the deviceID and autopilot HWID associated with the device.
.NOTES
    For more information on this API call, see: https://app.ninjarmm.com/apidocs/?links.active=core#/devices/getCustomFieldsReport
#>
function Get-NinjaRMMDevicesWithAutopilotField {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Security.SecureString]
        $AccessToken,

        [Parameter(Mandatory)]
        [int]
        $OrganizationID
    )

    try {
        $RawDevices = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/queries/custom-fields?df=org=$($OrganizationID)&fields=autopilotHwid" -Authentication OAuth -Token $AccessToken | Select-Object -ExpandProperty results
    }
    catch {
        Write-Error -Message "Error fetching report from the NinjaRMM API."
    }

    # Cleanup raw data and put in to a usable hashtable
    $Devices = @()
    foreach ($RawDevice in $RawDevices) {
        if ($RawDevice.fields.autopilotHwid) {
            $Devices += @(
                [pscustomobject]@{
                    DeviceID = $RawDevice.deviceId;
                    AutopilotHWID = $RawDevice.fields.autopilotHwid;
                }
            )
        }
    }

    return $Devices
}