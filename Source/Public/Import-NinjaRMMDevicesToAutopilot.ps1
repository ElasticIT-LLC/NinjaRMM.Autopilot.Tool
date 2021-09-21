<#
.SYNOPSIS
    This function exports devices from NinjaRMM and imports them to autopilot.
.DESCRIPTION
    A list of autopilot-ready devices will be exported from NinjaRMM and uploaded to the customer tenant.
.EXAMPLE
    Import-NinjaRMMDevicesToAutopilot
.PARAMETER ClientID
    The application client ID from the NinjaRMM dashboard.
.PARAMETER ClientSecret
    The generated client secret from the NinjaRMM dashboard.
.PARAMETER OrganizationID
    Int - The ID of the organization in NinjaRMM.
.PARAMETER CustomerID
    String - The ID of the customer tenant from Microsoft Partner Center.
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
        $Devices = Get-NinjaRMMAutopilotDevices -ClientID $ClientID -ClientSecret $ClientSecret -OrganizationID $OrganizationID

        Write-Host "Connecting to Partner Center..."
        Connect-PartnerCenter

        Write-Host "Creating device batch..."
        $Results = New-PartnerCustomerDeviceBatch -BatchId "NinjaRMM.Autopilot.Tool_$(Get-Date -Format FileDateTimeUniversal)" -CustomerID $CustomerID -Devices $Devices

        $CountSucceeded = 0
        $CountAlreadyEnrolled = 0
        $CountUnknownError = 0
        foreach ($Result in $Results.DevicesStatus) {
            switch ($Result.ErrorCode)
            {
                0 { $CountSucceeded++ }
                806 { $CountAlreadyEnrolled++ }
                Default { $CountUnknownError++ }
            }
        }
        Write-Host "Device(s) succeeded................: $($CountSucceeded)"
        Write-Host "Device(s) already enrolled.........: $($CountAlreadyEnrolled)"
        Write-Host "Device(s) failed with unknown error: $($CountUnknownError)"
    }
    catch {
        Write-Error -Message "An unknown error occurred."
    }
}