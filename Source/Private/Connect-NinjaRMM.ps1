function Connect-NinjaRMM {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $ClientID,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret
    )
 
    Get-NinjaRMMAccessToken -ClientID $ClientID -ClientSecret $ClientSecret
}