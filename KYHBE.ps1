#majority of this stuff is a relic from my time at KYHBE
$servername_ProdDeploy = "HFSNE121-037436.chfs.ds.ky.gov"
$hbeCredential = Import-Clixml -Path "$home\HBECredential.xml"
$dockerCredential = import-clixml -path "$home\dockerCredential.xml"
if (Test-Connection -ComputerName $servername_ProdDeploy -Count 1 -Quiet) {
    if (!(test-path e:\) -and !(get-psdrive | Where-Object name -eq 'E')) {New-PSDrive -Name E -PSProvider FileSystem -Root "\\$servername_ProdDeploy\e$" -Credential $hbeCredential} 
    if (!(get-psdrive | Where-Object name -eq 'scripts')) {new-psdrive -Name Scripts -PSProvider FileSystem -Root "\\$servername_ProdDeploy\scripts" -Credential $hbeCredential| Out-Null}
    Import-Module Scripts:\Get-Servers.psm1
}
#set CredSSP to enabled

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
}

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

    $pd = New-PSSession -ComputerName $servername_ProdDeploy -Authentication Credssp

if(test-connection $servername_ProdDeploy -Quiet -Count 1){invoke-command -ScriptBlock $scriptblock_KYHBE -NoNewScope}
#endregion


