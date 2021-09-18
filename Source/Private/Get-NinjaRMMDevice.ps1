function Get-NinjaRMMDevice {
    
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
        $NinjaRMMDevicesWithAutopilotHwid = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/queries/custom-fields?df=org=1&fields=autopilotHwid" -Authentication OAuth -Token $NinjaRMMAccessToken | Select-Object -ExpandProperty results
    }
    catch {
        Write-Error -Message "Error fetching devices from the NinjaRMM API."
    }

    return $NinjaRMMDevicesWithAutopilotHwid
}

Get-NinjaRMMDevice -NinjaRMMAccessToken "OoZOycMaCkcooNSUXO9m3tEl1tLzcpH3ILdymXW9aDk.vBv1vQTTd2zury-aO6cEUCGNDEYjlqwxghH1R_Jmy3g" -NinjaRMMOrganizationID "1"