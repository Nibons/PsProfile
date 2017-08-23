Write-Information "Starting PowerShell_ISE Profile"

#load the profile from the console
. "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
#edit console profile snippit:
#psedit ("{0}\Microsoft.PowerShell_profile.ps1" -f (split-path $profile -Parent))



#region KYHBE
$scriptblock_KYHBE = {
function update-HBECredential{
    #Param($hbecred = (Get-Credential ))
    $holdPSDefaultParameterValues = $PSDefaultParameterValues
    $PSDefaultParameterValues.Clear()
    $script:HBEcredential = (Get-Credential -Message "Please supply HBE Credentials")
    $HBEcredential | Export-Clixml "$home\hbeCredential.xml"
    $PSDefaultParameterValues = $holdPSDefaultParameterValues
}

if(test-path "$home\hbecredential.xml" ){$HBEcredential = Import-Clixml "$home\hbecredential.xml"} else{update-HBECredential}
if(test-path "$home\AzureCredential.xml" ){$AzureCredential = import-clixml "$home\AzureCredential.xml"} else {$script:AzureCredential = (get-credential -Message "Please Enter Azure Credential") ; $AzureCredential | export-clixml "$home\AzureCredential.xml"}

function sync-git {
Param(
    [cmdletbinding()]
    [Parameter(mandatory)]
    [string]$message,

    [string[]]$itemsToCommit = ".",

    $configInfo = @{
            localBranch = [string]'chaertzen'
            remoteBranch = [string]'ne-436'
            remotePath = [string]'e:\scripts'
            localPath = [string]"$home\scripts"
        }
    )
    #sign the scripts
    invoke-command -ComputerName hfsne121-037436 -ScriptBlock {ss} 
        
    #move to the remote server, and push the data
    set-location -path $configInfo['remotePath']
    git add $itemsToCommit
    git commit -m $message
    git push 
    
    #pull the data to the local location, and push the updated configs    
    set-location -path $configInfo['localPath'] 
    git checkout $configInfo['remoteBranch'] 
    git pull 
    git checkout $configInfo['localBranch'] 
    git merge $configInfo['remoteBranch']
    git push
}

$PSDefaultParameterValues = @{
    'new-PSSession:Credential' = $HBEcredential
    'invoke-command:credential' = $HBEcredential
    'enter-pssession:Credential' = $HBEcredential
    'new-psdrive:Credential' = $HBEcredential
    'restart-computer:Credential' = $HBEcredential
    '*-CimSession:Credential' = $HBEcredential
    #'import-module:Force' = [switch]::Present
    '*:Author' = "Clay Haertzen <chaertzen@deloitte.com>"
    "*:Company" = "Deloitte LLP"
}
$pd = New-PSSession -ComputerName $servername_ProdDeploy -Authentication Credssp
}
if(test-connection $servername_ProdDeploy -Quiet -Count 1){invoke-command -ScriptBlock $scriptblock_KYHBE -NoNewScope}
#endregion

#region SSH stuff
#$hostname = "flan.whatbox.ca"
#$SSHCredentials = get-credential
#$ssh = New-SSHSession -ComputerName $hostname -Credential $SSHCredentials
#endregion

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

#$VerbosePreference = "continue"
#clear-host