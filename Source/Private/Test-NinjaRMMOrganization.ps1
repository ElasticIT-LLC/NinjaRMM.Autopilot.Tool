<#
.SYNOPSIS
    Tests if the organization ID exists.
.PARAMETER AccessToken
    Security.SecureString - The OAuth 2.0 Access Token.
.PARAMETER OrganizationID
    Int - The ID of the organization in NinjaRMM.
.EXAMPLE
    Test-NinjaRMMOrganization -AccessToken $AccessToken -OrganizationID 1
    True
.OUTPUTS
    Test-NinjaRMMOrganization returns a boolean value. If the organization is valid, True will be returned.
#>
function Test-NinjaRMMOrganization {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Security.SecureString]
        $AccessToken,

        [Parameter(Mandatory)]
        [int]
        $OrganizationID
    )
        $ValidOrganizationID = $True
        try {
            Invoke-RestMethod -Method Get -Uri "https://app.ninjarmm.com/v2/organization/$($OrganizationID)" -Authentication OAuth -Token $AccessToken | Out-Null
        }
        catch {
            Write-Error -Message "The NinjaRMM organization ID does not exist."
            $ValidOrganizationID = $False
        }
    
    return $ValidOrganizationID
}