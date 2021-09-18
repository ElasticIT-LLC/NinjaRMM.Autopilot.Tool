# NinjaRMM.Autopilot.Tool

## Summary

This module syncs device information from NinjaRMM to Microsoft Intune for Autopilot enrollment. The module is currently under development and not ready for use.

## How does it work?

This module calls the NinjaRMM API to retrieve a listing of devices. It then uploads the serial number and hardware hash to Intune via the Graph API. By default, NinjaRMM only collects a serial number from the device. To collect the hardware hash, there is a bit of configuration required within NinjaRMM itself.

## How do I setup NinjaRMM?

### Configuring  automated collection of the hardware hash

The process of collecting the hardware hash relies on setting up a custom field to store the information within NinjaRMM. Additionally, a script will need to be ran on each computer that grabs the hash from the machine and saves it to your custom field in NinjaRMM. Thankfully, NinjaRMM allows you to schedule scripts to run automatically to make this a hands-off process.

1. In NinjaRMM, navigate to Configuration > Devices > Role Custom Fields. Click Add in the top right corner.
2. Fill out the following information and click Create.
   1. Label - Autopilot HWID
   2. Name - autopilotHwid
   3. Field Type - Text
3. Once the next page loads, fill out the following information and click Save.
   1. Technician - Read Only
   2. Scripts - Read/Write
4. The newly created field now needs assigned to a device role. Navigate to Configuration > Devices > Roles.
5. Hover over Windows Desktops and Laptops and select Edit.
6. Click the Add button, and select Field.
7. Choose Autopilot HWID from the dropdown and click Add. Then, click Save.

At this point, you should be able to navigate to any Windows device within NinjaRMM and see the Autopilot HWID field on the Custom Fields tab. This is great and all, but now we need to populate that field.

I am going to assume that you know how to create a script in NinjaRMM. I will also assume that you know how to schedule scripts to run automatically. With all that being said, here is the script you will need to create and schedule in NinjaRMM:

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not(Get-InstalledModule PowerShellGet -ErrorAction silentlycontinue)) {
  Try {
    Install-PackageProvider NuGet -Force | Out-Null
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module PowerShellGet -Force
  } Catch {
    Write-Host "There was an error installing NuGet or PowerShellGet."
    Exit 1
  }
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
Install-Script -Name Get-WindowsAutoPilotInfo -Force

$HWID = Get-WindowsAutoPilotInfo.ps1

Ninja-Property-Set autopilotHwid $HWID."Hardware Hash"
```

### Configuring API Access 

The next step is obtaining API credentials from NinjaRMM so that the tool can retrieve the device information.

1. In NinjaRMM, navigate to Configuration > Integrations > API > Client App IDs. Click Add in the top right corner.
2. Fill out the following information and click Save. You will be presented with a client secret upon saving. Make sure you save the client secret as there is no way to view it again.
   1. Application platform - API Services
   2. Name - NinjaRMM.Autopilot
   3. Scopes - Check all available options
   4. Allowed Grant Types - Client Credentials
3. Copy and save the Client ID of the newly created NinjaRMM.Autopilot application.

## How do I use this tool?

