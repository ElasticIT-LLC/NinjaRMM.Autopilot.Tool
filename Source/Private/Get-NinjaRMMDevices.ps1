function Get-NinjaRMMDevices {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $NinjaRMMAccessToken,

        [Parameter(Mandatory)]
        [string]
        $NinjaRMMOrganizationID
    )
    $NinjaRMMAccessToken = ConvertTo-SecureString $NinjaRMMAccessToken -AsPlainText -Force
    try {
        $NinjaRMMDevicesWithAutopilotHwid = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/queries/custom-fields?df=org=1&fields=autopilotHwid" -Authentication OAuth -Token $NinjaRMMAccessToken  | Select-Object -ExpandProperty results
    }
    catch {
        Write-Error -Message "Error fetching devices from the NinjaRMM API."
    }

    return $NinjaRMMDevicesWithAutopilotHwid
}
