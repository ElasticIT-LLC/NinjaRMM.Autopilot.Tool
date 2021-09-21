<#
.SYNOPSIS
    This function exports devices from NinjaRMM and imports them to autopilot.
.DESCRIPTION
    A list of autopilot-ready devices will be exported from NinjaRMM and uploaded to the customer tenant.
.EXAMPLE
    Import-NinjaRMMDevicesToAutopilot
    Explanation of what the example does
.PARAMETER ClientID
    The application client ID from the NinjaRMM dashboard.
.PARAMETER ClientSecret
    The generated client secret from the NinjaRMM dashboard.
.PARAMETER OrganizationID
    Int - The ID of the organization in NinjaRMM.
.PARAMETER CustomerID
    String - The ID of the customer tenant from Microsoft Partner Center.
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
            $Devices = Get-NinjaRMMAutopilotDevices -ClientID $ClientID -ClientSecret $ClientSecret -OrganizationID $OrganizationID

            Write-Host "Connecting to Partner Center..."
            Connect-PartnerCenter

            Write-Host "Creating device batch..."
            $Results = New-PartnerCustomerDeviceBatch -BatchId "NinjaRMM.Autopilot.Tool_$(Get-Date -Format FileDateTimeUniversal)" -CustomerID $CustomerID -Devices $Devices

            # Report statistics
            $success = 0
            $failure = 0
            $Results.DevicesStatus | ForEach-Object {
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
    catch {
        Write-Error -Message "An unknown error occurred."
    }

    return $Results.DevicesStatus
}