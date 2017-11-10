Write-Information "Starting PowerShell_ISE Profile"

#load the profile from the console
. "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
#edit console profile snippit:
#psedit ("{0}\Microsoft.PowerShell_profile.ps1" -f (split-path $profile -Parent))



if(test-path "$home\AzureCredential.xml" ){$AzureCredential = import-clixml "$home\AzureCredential.xml"} else {$script:AzureCredential = (get-credential -Message "Please Enter Azure Credential") ; $AzureCredential | export-clixml "$home\AzureCredential.xml"}



$PSDefaultParameterValues = @{
    'new-PSSession:Credential' = $HPSCredential
    'invoke-command:credential' = $HPSCredential
    'enter-pssession:Credential' = $HPSCredential
    'new-psdrive:Credential' = $HPSCredential
    'restart-computer:Credential' = $HPSCredential
    '*-CimSession:Credential' = $HPSCredential
    #'import-module:Force' = [switch]::Present
    '*:Author' = "Clay Haertzen <Clay.haertzen@e-hps.com>"
    "*:Company" = "HPS"
    'import-module:verbose' = $false
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

#$VerbosePreference = "continue"
#clear-host