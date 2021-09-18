<#
.SYNOPSIS
    Obtains an access token from the NinjaRMM API
.DESCRIPTION
    This function follows the standard OAuth 2.0 Client Credentials Grant. In exchange for a client ID and client Secret, an access token is obtained. This access token can be used on all subsequent API calls.
.PARAMETER ClientID
    The application client ID from the NinjaRMM dashboard.
.PARAMETER ClientSecret
    The generated client secret from the NinjaRMM dashboard.
.EXAMPLE
    Get-NinjaRMMAccessToken -ClientID "xyz" -ClientSecret "abc"
    abcdef12345 
.OUTPUTS
    Get-NinjaRMMAccessToken returns a string with the access token.
.NOTES
    For more information on creating the OAuth 2.0 application in NinjaRMM, navigate here: https://ninjarmm.zendesk.com/hc/en-us/articles/4403617211277-OAuth-Token-Configuration
#>

function Get-NinjaRMMAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $ClientID,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret
    )

    try {
        $Body = @{
            grant_type    = 'client_credentials'
            client_id     = $ClientID
            client_secret = $ClientSecret
            scope         = "monitoring management control"
        }
        $NinjaRMMAccessToken = Invoke-RestMethod -Method Post -Uri 'https://app.ninjarmm.com/oauth/token' -Body $Body | Select-Object -ExpandProperty access_token
    }
    catch {
        Write-Error -Message "Error authenticating with the NinjaRMM API."
    }

    return $NinjaRMMAccessToken
}