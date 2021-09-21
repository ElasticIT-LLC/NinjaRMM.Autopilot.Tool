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