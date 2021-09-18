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
    Get-NinjaRMMCustomFieldsReport -AccessToken $AccessToken -OrganizationID 1
    deviceId fields
    -------- ------
           1 @{autopilotHwid=A0HjAgEAHAAAAAoAfwZxyKCgBWBGFKXTOzKPACCQUCABAACQABAAgAEAA...
.OUTPUTS
    Get-NinjaRMMCustomFieldsReport returns a hashtable of the deviceID and custom fields associated with the device.
.NOTES
    For more information on this API call, see: https://app.ninjarmm.com/apidocs/?links.active=core#/devices/getCustomFieldsReport
#>
function Get-NinjaRMMCustomFieldsReport {
    
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
        $CustomFieldsReport = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/queries/custom-fields?df=org=$($OrganizationID)&fields=autopilotHwid" -Authentication OAuth -Token $AccessToken | Select-Object -ExpandProperty results
    }
    catch {
        Write-Error -Message "Error fetching devices from the NinjaRMM API."
    }

    return $CustomFieldsReport
}

#Get-NinjaRMMDevice -NinjaRMMAccessToken "OoZOycMaCkcooNSUXO9m3tEl1tLzcpH3ILdymXW9aDk.vBv1vQTTd2zury-aO6cEUCGNDEYjlqwxghH1R_Jmy3g" -NinjaRMMOrganizationID "1"