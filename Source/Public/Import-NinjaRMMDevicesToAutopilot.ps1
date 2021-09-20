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
        $OrganizationID,

        [Parameter(Mandatory)]
        [string]
        $CustomerID
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
                
                $Device = New-Object -TypeName Microsoft.Store.PartnerCenter.PowerShell.Models.DevicesDeployment.PSDevice
                $Device.HardwareHash = $AutopilotDevice.AutopilotHWID
                $Device.SerialNumber = $DeviceSerial
                $Devices += $Device
            }
            Write-Host "$($Devices.Count) device(s) are ready for Autopilot import!"

            Write-Host "Connecting to Partner Center..."
            Connect-PartnerCenter -UseDeviceAuthentication

            Write-Host "Creating device batch..."
            $Results = New-PartnerCustomerDeviceBatch -BatchId "NinjaRMM.Autopilot.Tool_$(Get-Date -Format FileDateTimeUniversal)" -CustomerID $CustomerID -Devices $Devices

            # Report statistics
            $success = 0
            $failure = 0
            $Results.DevicesStatus | % {
                if ($_.ErrorCode -eq 0) {
                    $success++
                }
                else
                {
                    $failure++
                }
            }
            Write-Host "Batch processed."
            Write-Host "Devices successfully added = $success"
            Write-Host "Devices not added due to errors = $failure"

            # Return the list of results
            
        }
    }
    catch {
        Write-Error -Message "An unknown error occurred."
    }

    return $Results.DevicesStatus
}