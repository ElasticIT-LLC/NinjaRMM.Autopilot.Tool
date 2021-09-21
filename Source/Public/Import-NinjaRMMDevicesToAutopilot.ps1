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
            $Devices = Get-NinjaRMMAutopilotDevices -ClientID $ClientID -ClientSecret $ClientSecret -OrganizationID $OrganizationID
            
            Write-Host "Connecting to Partner Center..."
            Connect-PartnerCenter -UseDeviceAuthentication

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