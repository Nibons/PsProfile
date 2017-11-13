Write-Information "Starting PowerShell_VSCode Profile"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

#load the profile from the ISE console
$ISEProfile = measure-command {. "$PSScriptRoot\Microsoft.PowerShellISE_profile.ps1"}
Write-Verbose "Loading ISE Profile took $($ISEProfile.TotalSeconds) seconds."

#clear-host