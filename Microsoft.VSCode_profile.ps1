$VerbosePreference = "continue"
Write-Information "Starting PowerShell_VSCode Profile"

#load the profile from the ISE console
. "$PSScriptRoot\Microsoft.PowerShellISE_profile.ps1"

$env:root_scripts = "$home\scripts"



#clear-host