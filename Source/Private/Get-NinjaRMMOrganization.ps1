function Get-NinjaRMMOrganization {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $AccessToken,

        [Parameter]
        [int]
        $OrganizationID
    )
    
    $SecureAccessToken = ConvertTo-SecureString -String $AccessToken -AsPlainText -Force

    if ($PSBoundParameters.ContainsKey('OrganizationID'))
    {
        try {
            $Organization = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/organization/$($OrganizationID)" -Authentication OAuth -Token $SecureAccessToken  
        }
        catch {
            Write-Error -Message "Error communicating with the NinjaRMM API."
        }

    } else {
        try {
            $Organization = Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/organizations" -Authentication OAuth -Token $SecureAccessToken
        }
        catch {
            Write-Error -Message "Error communicating with the NinjaRMM API."
        }
    }
    
    return $Organization
}

Get-NinjaRMMOrganization -AccessToken "OoZOycMaCkcooNSUXO9m3tEl1tLzcpH3ILdymXW9aDk.7sDk0oW9LNpvV9idk6Bjvg6U883rEOaBuvGwqgY_ec4" -OrganizationID 1