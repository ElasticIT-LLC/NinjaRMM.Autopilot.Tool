<#
.SYNOPSIS
    This function exports devices from NinjaRMM and imports them to autopilot.
.DESCRIPTION
    Long description
.EXAMPLE
    Import-NinjaRMMDevicesToAutopilot
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Import-NinjaRMMDevicesToAutopilot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ClientID,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret,

        [Parameter(Mandatory)]
        [int]
        $OrganizationID
    )
    
    try {
        Write-Host "Getting NinjaRMM API access token..."
        $NinjaRMMAccessToken = Get-NinjaRMMAccessToken -ClientID $ClientID -ClientSecret $ClientSecret

        Write-Host "Checking if NinjaRMM organization ID is valid..."
        if ((Test-NinjaRMMOrganization -AccessToken $NinjaRMMAccessToken -OrganizationID $OrganizationID) -eq $True) {
            
            Write-Host "Getting NinjaRMM devices with an Autopilot HWID..."
            $AutopilotDevices = Get-NinjaRMMAutopilotDevices -AccessToken $NinjaRMMAccessToken -OrganizationID $OrganizationID

            Write-Host "Getting NinjaRMM device serials..."
            $Devices = @()
            foreach ($AutopilotDevice in $AutopilotDevices) {
                $DeviceSerial = Get-NinjaRMMDeviceSerial -AccessToken $NinjaRMMAccessToken -DeviceID $AutopilotDevice.DeviceID
                $Devices += @(
                    [pscustomobject]@{
                        DeviceID = $AutopilotDevice.DeviceID;
                        Serial = $DeviceSerial;
                        AutopilotHWID = $AutopilotDevice.AutopilotHWID;
                    }
                )
            }
            Write-Host "$($Devices.Count) device(s) are ready for Autopilot import!"
        }
    }
    catch {
        Write-Error -Message "An unknown error occurred."
    }

    return $Devices
}