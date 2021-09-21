<#
.SYNOPSIS
    Fetches a list of devices that are ready for autopilot from NinjaRMM.
.EXAMPLE
    Get-NinjaRMMAutopilotDevices
    DeviceId SerialNumber                     ProductKey ModelName OemManufacturerName UploadedDate
    -------- ------------                     ---------- --------- ------------------- ------------
             CND8370M1D                                                                1/1/0001 12:00:00 AM

.PARAMETER ClientID
    The application client ID from the NinjaRMM dashboard.
.PARAMETER ClientSecret
    The generated client secret from the NinjaRMM dashboard.
.PARAMETER OrganizationID
    Int - The ID of the organization in NinjaRMM.
.PARAMETER AsCsv
    Switch - Exports the device list to a CSV file in the current directory.
.OUTPUTS
    Get-NinjaRMMAutopilotDevices returns a hashtable of devices ready for Autopilot import. Optionally, -AsCsv can be used to return a CSV file of the device listing.
.NOTES
    General notes
#>
function Get-NinjaRMMAutopilotDevices {
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

        [Parameter()]
        [switch]
        $AsCsv
    )
    
    try {
        Write-Host "Getting NinjaRMM API access token..."
        $NinjaRMMAccessToken = Get-NinjaRMMAccessToken -ClientID $ClientID -ClientSecret $ClientSecret

        Write-Host "Checking if NinjaRMM organization ID is valid..."
        if ((Test-NinjaRMMOrganization -AccessToken $NinjaRMMAccessToken -OrganizationID $OrganizationID) -eq $True) {
            
            Write-Host "Getting NinjaRMM devices with an Autopilot HWID..."
            $AutopilotDevices = Get-NinjaRMMDevicesWithAutopilotField -AccessToken $NinjaRMMAccessToken -OrganizationID $OrganizationID

            Write-Host "Getting NinjaRMM device serials..."
            $Devices = @()
            $DevicesCompleted = 1
            foreach ($AutopilotDevice in $AutopilotDevices) {
                #Load Progress Bar
                $PercentComplete = $(($DevicesCompleted / $AutopilotDevices.Count) * 100 )
                $Progress = @{
                    Activity = "Getting serial information for NinjaRMM device ID '$($AutopilotDevice.DeviceID)'."
                    Status = "Processing $DevicesCompleted of $($AutopilotDevices.Count)"
                    PercentComplete = $([math]::Round($PercentComplete, 2))
                }
                Write-Progress @Progress -Id 1

                $DeviceSerial = Get-NinjaRMMDeviceSerial -AccessToken $NinjaRMMAccessToken -DeviceID $AutopilotDevice.DeviceID
                
                $Device = New-Object -TypeName Microsoft.Store.PartnerCenter.PowerShell.Models.DevicesDeployment.PSDevice
                $Device.HardwareHash = $AutopilotDevice.AutopilotHWID
                $Device.SerialNumber = $DeviceSerial
                $Devices += $Device

                $DevicesCompleted ++
            }
        }
    }
    
    catch {
        Write-Error "There was an error fetching autopilot devices from the NinjaRMM API."
    }
    
    if ($AsCsv.IsPresent) {
        $Devices | Export-Csv -NoTypeInformation -Path .\NinjaRMMAutopilotDevices.csv
        Write-Host "The CSV has been saved to the current directory."
    } else {
        return $Devices
    }
}